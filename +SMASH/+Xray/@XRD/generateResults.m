% GENERATERESULTS - integrate 2D diffraction pattern
%
% This method integrates the processed 2D diffraction pattern into a
% standard 1D intensity vs 2θ plot. Users can incorporate pixel splitting 
% per a MATLAB vectorized version of pyFAI's bbox pixel splitting method.
% Users can also choose to apply LP corrections (default is to not apply LP
% corrections and then compare results to LP-corrected predictions).
%
% Usage:
%   >> obj = generateResults(obj)
%
% created May, 2023 by Nathan Brown (Sandia National Laboratories)
% updated June, 2023 by Nathan Brown
% updated August, 2026 by Nathan Brown to incorporate pixel splitting and
%                                      LP corrections
%
function obj = generateResults(obj)

% check that we have data

if isnumeric(obj.detector.image)
    return
end

% pull out needed variables (and cast into appropriate dimensions)

crystalCenter = reshape(obj.crystal.location, 1, 1, 3);
cdata = obj.detector.image.Data;
s0 = ones(size(cdata));
s0 = cat(3, s0*obj.source.s0(1), s0*obj.source.s0(2), s0*obj.source.s0(3));
twoThetaRes = obj.results.twoThetaResolution;
edges = 0:twoThetaRes:180; % not using linspace to exactly honor input res
if edges(end) < 180
    edges = [edges, edges(end)+twoThetaRes];
end
sizeN = [1, numel(edges)-1];

if ~obj.results.splitPixels % standard binning of a single pixel into a single bin

    % compute theta values

    coords = findPixelCoordinates(obj);
    v = coords - crystalCenter;
    v = v ./ vecnorm(v,2,3);
    twoTheta = acosd(dot(v,s0,3) ./ vecnorm(s0,2,3)); % v has unity magnitude

    % pair down to cdata > 0

    goodInd = cdata > 0;
    cdata = cdata(goodInd);
    twoTheta = twoTheta(goodInd);

    % apply vector-specific polarization correction

    if obj.results.applyLPCorrection
        cdata = cdata ./ polarizationCorrection(...
            obj.source.polarizationFraction, obj.source.polarizationVector, ...
            twoTheta, v, goodInd);
    end

    % bin and sum intensities at each twoTheta. Went with manual binning
    % for speed since we have even bins. I maintain the histcounts
    % convention of not including the right edge, except at the end.

    bin = floor(twoTheta/twoThetaRes) + 1; % b/c we have even bins and first edge is 0
    bin(bin > sizeN(2)) = sizeN(2); % be inclusive on right edge in last bin
    rIntensity = accumarray(bin(:), cdata(:));

else % binning of pixels into multiple bins via bbox 

    % compute the theta values of the grid corners and use these to
    % estimate the theta spread of each pixel

    [~, ~, coords] = findPixelCoordinates(obj,'none',true);
    twoTheta = nan(size(coords{1},1),size(coords{1},2),numel(coords));
    for ii = 1:numel(coords) % faster to iterate through cell than use a big matrix
        v = coords{ii} - crystalCenter;
        twoTheta(:,:,ii) = acosd(dot(v,s0,3) ./ (vecnorm(v,2,3) .* vecnorm(s0,2,3)));
    end
    twoThetaLow = reshape(min(twoTheta,[],3),1,[]);
    twoThetaHigh = reshape(max(twoTheta,[],3),1,[]);

    % pair down the search to only pixels containing data

    cdata = reshape(cdata,1,[]);
    goodInd = cdata > 0;
    cdata = cdata(goodInd);
    twoThetaLow = twoThetaLow(goodInd);
    twoThetaHigh = twoThetaHigh(goodInd);

    % apply vector-specific polarization correction, using the values from
    % the pixel center as an approximation to speed up calculation

    if obj.results.applyLPCorrection
        coords = findPixelCoordinates(obj);
        v = coords - crystalCenter;
        v = v ./ vecnorm(v,2,3);
        twoTheta = acosd(dot(v,s0,3) ./ vecnorm(s0,2,3));
        twoTheta = transpose(twoTheta(goodInd));
        cdata = cdata ./ transpose(polarizationCorrection(...
            obj.source.polarizationFraction, obj.source.polarizationVector, ...
            twoTheta, v, goodInd));
    end

    % construct the corresponding bin index and enlarge cdata to match
    %
    % The bin columns are pixels and the bin rows increment to span the
    % bin indices across which each pixel is spread. The final rows in most 
    % columns contain fictitious data beyond the span that is later deleted 
    % (necessary because the total row number is set by the pixel with the
    % largest span). 
    % 
    % A corner on a bin right edge is counted as part of that bin but then 
    % assigned a weight of zero for that bin, so the counting still adheres 
    % to the histcounts convention of not including right edges.
    %
    % This scales poorly with high resolution because it requires the
    % creation of a huge matrix... but it runs pretty quickly at moderate
    % resolution, so I'm keeping the approach for now.

    indLo = twoThetaLow/twoThetaRes; % b/c we have even bins and first edge is 0
    indHi = twoThetaHigh/twoThetaRes;
    indLoCeil = ceil(indLo);
    indHiCeil = ceil(indHi);
    incr = indHiCeil - indLoCeil;

    bin = indLoCeil + (0:max(incr))';
    cdata = repmat(cdata, size(bin,1), 1);

    % compute the weights to account for total spread across the bins and
    % fractional bin coverage.  

    w = ones(size(bin));
    w(1,:) = indLoCeil - indLo; % fractional coverage on low end
    w(bin == indHiCeil) = indHi - floor(indHi); % fractional coverage on high end
    w = w ./ ((twoThetaHigh-twoThetaLow)/twoThetaRes); % normalize by number of bins spanned by the pixel
    w(w>1) = 1; % account for pixels that only span one bin (will always be first row value high end fractional coverage greater than unity)

    % trim and reshape for input into accumarray (now we get rid of the
    % fictitious stuff)
    
    deleteInd = bin > indHiCeil; % fictitious part of the bin
    bin(deleteInd) = [];
    cdata(deleteInd) = [];
    w(deleteInd) = [];

    % sum the weighted intensity in each bin

    rIntensity = accumarray(transpose(bin), transpose(cdata.*w));

end

% define twoTheta

twoTheta = edges(1:end-1) + twoThetaRes/2;
ind = 1:max(bin(:));

% average results (usually faster to use two accumarray calls than use @mean)

if obj.results.average
    if obj.results.splitPixels
        rIntensity = rIntensity ./ accumarray(bin(:), w(:));
    else
        rIntensity = rIntensity ./ accumarray(bin(:), 1);
    end
end

% apply the Lorentz corrections

if obj.results.applyLPCorrection

    % window down theta

    twoThetaSmall = twoTheta(ind);
    indL = rIntensity > 0;
    twoThetaSmall = transpose(twoThetaSmall(indL));

    % reciprocal lattice intersection probability correction

    rIntensity(indL) = rIntensity(indL) ./ ...
        (cosd(sind(twoThetaSmall/2)) ./ sind(twoThetaSmall));

    % average linear density correction (see generatePrediction for
    % details)

    x = transpose(linspace(min(twoThetaSmall), max(twoThetaSmall), 100));
    obj.results.s = sCone(x, obj.source.s0);
    obj = findSpotLocations(obj,'results');
    L = lorentzLinearDensity(obj.results.spotLocations);
    L = interp1(x, L, twoThetaSmall);
    rIntensity(indL) = rIntensity(indL) ./ L;
    obj.results = rmfield(obj.results,'s');
    obj.results = rmfield(obj.results,'spotLocations');

end

% subtract out background and normalize

originalMin = min(rIntensity(rIntensity > 1e-6));
normIntensity = rIntensity - originalMin;
normIntensity(isnan(normIntensity) | isinf(normIntensity) | ...
    normIntensity <= 0) = 0;
finalMax = max(normIntensity);
normIntensity = normIntensity/finalMax;

% register intensity with theta

rawIntensity = zeros(sizeN);
rawIntensity(ind) = rIntensity;
normalizedIntensity = zeros(sizeN);
normalizedIntensity(ind) = normIntensity;

% save results

obj.results.twoTheta = twoTheta;
obj.results.rawIntensity = rawIntensity;
obj.results.normalizedIntensity = normalizedIntensity;

end

function p = polarizationCorrection(f, pvec, twoTheta, v, goodInd)
p0 = 0.5*(1 + cosd(twoTheta).^2); % unpolarized
p1 = 0;
if f > 0
    v = reshape(v(repmat(goodInd,1,1,3)),[],3); % columns are x,y,z
    pvec = repmat(pvec ./ vecnorm(pvec,2,2),numel(twoTheta),1);
    p1 = 1 - dot(v,pvec,2).^2; % comp 1
end
p = ((1-f)*p0 + f*p1);
end