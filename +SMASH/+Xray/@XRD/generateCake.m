% GENERATECAKE - create 2θ-χ projection
%
% This method creates a 2θ-χ projection from the detector diffraction
% pattern. The 2θ and χ resolutions, the χ reference rotation angle, and 
% the pixel splitting toggle are set by changeObject. The method generates 
% and shows the image and saves the raw 2θ and χ values for each grid 
% center by default, but optional input flags can alter this behavior.
%
% For consistency, this method uses the same χ reference vector employed to
% generate simulated diffraction rings in generatePrediction (see paper).
% The user can rotate this reference with the results.cake.chiRotation 
% property.
%
% This method uses PyFAI's bbox pixel splitting method.
%
% Usage:
%   >> obj = generateCake(obj)
%   >> obj = generateCake(obj, makeImage, viewImage, outputRaw)
%       -> Optional inputs are all logicals whose defaults are true
%
% created August, 2026 by Nathan Brown (Sandia National Laboratories)
%
function [obj, h, im] = generateCake(obj, varargin)

% check that we have something to compute

assert(isa(obj.detector.image, 'SMASH.ImageAnalysis.Image'), ...
    'No detector image!');

% delete old

if isfield(obj.results.cake, 'image')
    obj.results.cake = rmfield(obj.results.cake,'image');
end
if isfield(obj.results.cake, 'twoTheta')
    obj.results.cake = rmfield(obj.results.cake,'twoTheta');
end
if isfield(obj.results.cake, 'chi')
    obj.results.cake = rmfield(obj.results.cake,'chi');
end
obj.match.rings.expLineouts = [];

% parse inputs 

twoThetaRes = obj.results.cake.twoThetaResolution;
chiRes = obj.results.cake.chiResolution;
rotAng = obj.results.cake.chiRotation;
splitPixels = obj.results.cake.splitPixels;

makeImage = true;
viewImage = true;
outputRaw = true;
if nargin > 1
    makeImage = varargin{1};
end
if nargin > 2
    viewImage = varargin{2};
end
if nargin > 3
    outputRaw = varargin{3};
end
if viewImage && ~makeImage
    warning('User requested to view an image but not to make it');
end

% pull out needed variables

obj = findStraightThruLocation(obj, true);
coords = findPixelCoordinates(obj);
cdata = obj.detector.image.Data;
crystalCenter = obj.crystal.location;
s0 = obj.source.s0/vecnorm(obj.source.s0,2,2);
straightThru = obj.prediction.straightThruLocation;

% determine the chi reference vector the same way it's done in
% generatePrediction

if s0(3) == 0
    a = [0 0 1];
else
    a = [1 1 -(s0(1)+s0(2))/s0(3)];
end

% apply rotation to chi reference vector per user input

if ~isnan(rotAng) && rotAng ~= 0
    a = a*cosd(rotAng) + cross(s0,a)*sind(rotAng) + ...
        s0*dot(s0,a)*(1-cosd(rotAng));
end
a = a/norm(a);

% recast and explicitly expand where necessary

crystalCenter = reshape(crystalCenter,1,1,3);
straightThru = reshape(straightThru,1,1,3);
s0 = repmat(reshape(s0,1,1,3), size(cdata,1), size(cdata,2));
a = repmat(reshape(a,1,1,3), size(cdata,1), size(cdata,2));

% compute theta and chi

v = coords - crystalCenter;
twoTheta = acosd(dot(v,s0,3) ./ vecnorm(v,2,3)); % s0 and v are 1

v = coords - straightThru;
chi = atan2d(dot(s0,cross(v,a,3),3), dot(v,a,3)); % signing based on rotation about s0

% store values in results

if outputRaw
    obj.results.cake.twoTheta = twoTheta;
    obj.results.cake.chi = chi;
end

h = -1;

if makeImage % image binning (see generateResults for detailed explanations)

    % set edges and create empty image

    twoThetaEdge = 0:twoThetaRes:180; 
    if twoThetaEdge(end) < 180
        twoThetaEdge = [twoThetaEdge, twoThetaEdge(end)+twoThetaRes];
    end
    chiEdge = -180:chiRes:180+chiRes;
    if chiEdge(end) < 180
        chiEdge = [chiEdge, chiEdge(end) + chiRes];
    end
    x = twoThetaEdge(1:end-1) + twoThetaRes/2;
    y = chiEdge(1:end-1) + chiRes/2;
    numY = numel(y);
    dat = zeros(numY, numel(x));

    if ~splitPixels % direct binning

        % I handle 2D indexing by combining the two bins into a single
        % linearly indexed bin (same result as calling sub2ind)

        goodInd = cdata > 0;
        cdata = cdata(goodInd);
        twoTheta = twoTheta(goodInd);
        chi = chi(goodInd);

        binX = floor(twoTheta/twoThetaRes)+1;
        binY = floor((chi-chiEdge(1))/chiRes)+1;
        bin = binY + (binX-1)*numY; % combined bin to handle 2D

        ind = 1:max(bin(:));
        dat(ind) = accumarray(bin(:), cdata(:));

        if obj.results.cake.average
            dat(ind) = dat(ind) ./ accumarray(bin(:),1)'; % usually faster to do two accumarrays than @mean
            dat(isnan(dat)) = 0;
        end

    else % pixel splitting

        % compute twoTheta and chi at the pixel corners

        [~, ~, coords] = findPixelCoordinates(obj,'none',true);
        twoTheta = nan(size(twoTheta,1),size(twoTheta,2),4);
        chi = twoTheta;
        for ii = 1:numel(coords) % faster to iterate through cell than manipulate large matrix 
            v = coords{ii} - crystalCenter;
            twoTheta(:,:,ii) = acosd(dot(v,s0,3) ./ vecnorm(v,2,3)); % s0 and v are 1
            v = coords{ii} - straightThru;
            chi(:,:,ii) = atan2d(dot(s0,cross(v,a,3),3), dot(v,a,3)); % signing based on rotation
        end
        clear('coords', 'v', 's0', 'a');

        % determine pixel bounds

        twoThetaLow = reshape(min(twoTheta,[],3),1,[]);
        twoThetaHigh = reshape(max(twoTheta,[],3),1,[]);
        clear('twoTheta');
        chiLow = reshape(min(chi,[],3),1,[]);
        chiHigh = reshape(max(chi,[],3),1,[]);
        clear('chi');

        % trim data

        cdata = reshape(cdata,1,[]);
        goodInd = cdata > 0;
        cdata = cdata(goodInd);
        twoThetaLow = twoThetaLow(goodInd);
        twoThetaHigh = twoThetaHigh(goodInd);
        chiLow = chiLow(goodInd);
        chiHigh = chiHigh(goodInd);
        clear('goodInd');

        % pre-compute useful quantities

        area = ((twoThetaHigh - twoThetaLow)/twoThetaRes) .* ...
            ((chiHigh - chiLow)/chiRes); % bin area covered by pixel

        ttIndLo = twoThetaLow/twoThetaRes;
        ttIndHi = twoThetaHigh/twoThetaRes;
        clear('twoThetaLow','twoThetaHigh');
        ttIndLoCeil = ceil(ttIndLo); % first index
        ttIndHiCeil = ceil(ttIndHi); % last index
        ttFracLo = ttIndLoCeil - ttIndLo; % fractional coverage in first grid
        ttFracHi = ttIndHi - floor(ttIndHi); % fractional coverage in last grid
        clear('ttIndLo', 'ttIndHi');

        cIndLo = (chiLow - chiEdge(1))/chiRes;
        cIndHi = (chiHigh - chiEdge(1))/chiRes;
        clear('chiLow', 'chiHigh');
        cIndLoCeil = ceil(cIndLo);
        cIndHiCeil = ceil(cIndHi);
        cFracLo = cIndLoCeil - cIndLo;
        cFracHi = cIndHi - floor(cIndHi);
        clear('cIndLo', 'cIndHi');

        if obj.results.cake.average
            countVal = zeros(size(dat));
        end

        % loop through pixels and individually spread their intensities
        % across the appropriate bins (have to loop because even moderate
        % resolutions will generate enormous arrays)

        for ii = 1:numel(cdata)

            % determine indices

            binT = transpose(ttIndLoCeil(ii):ttIndHiCeil(ii));
            binC = transpose(cIndLoCeil(ii):cIndHiCeil(ii));

            % form weight matrix

            n = numel(binT);
            wT = ones(1,n); % row
            if n > 1 % only want fractional coverages if we extend beyond a single bin
                wT(1) = ttFracLo(ii);
                wT(end) = ttFracHi(ii);
            end

            n = numel(binC);
            wC = ones(n,1); % column
            if n > 1
                wC(1) = cFracLo(ii);
                wC(end) = cFracHi(ii);
            end

            w = wT .* wC; % fraction of pixel covered is just LxW
            w = w / area(ii); % normalize by bin area

            % update array

            binY = repmat(binC,numel(binT),1); % need rows to advance every time
            binX = repelem(binT,numel(binC),1); % need columns to only advance every cycle
            bin = binY + (binX-1)*numY; % linear index in order of weights
            dat(bin) = dat(bin) + w(:)*cdata(ii);

            if obj.results.cake.average
                countVal(bin) = countVal(bin) + w(:);
            end

        end

        if obj.results.cake.average
            countVal(countVal == 0) = 1;
            dat = dat ./ countVal;
            clear('countVal');
        end

    end

    % image creation

    im = SMASH.ImageAnalysis.Image(x, y, dat);
    im.GraphicOptions.ColorMap = 'parula';
    im.DataLabel = 'Intensity';
    if any(dat(:))
        xlims = x([find(any(dat,1),1,'first'), ...
            find(any(dat,1),1,'last')]) + [-1 1]*twoThetaRes;
        ylims = y([find(any(dat,2),1,'first'), ...
            find(any(dat,2),1,'last')]) + [-1 1]*chiRes;
        im = limit(im,xlims,ylims);
    end
    im.Grid1Label = '2θ (deg)';
    im.Grid2Label = 'χ (deg)';
    im.Name = 'Cake Plot';
    im.GraphicOptions.Title = im.Name;

    % show figure

    if viewImage
        h = view(im);
        h = h.figure;
    end

    obj.results.cake.image = im;

end

end