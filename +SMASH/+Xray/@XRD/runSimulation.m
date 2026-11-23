% RUNSIMULATION - simulate diffraction pattern
%
% This method simulates a diffraction pattern by combining together many
% single-crystal predictions.
%
% Usage:
%   >> obj = runSimulation(obj)
%
% created December, 2023 by Nathan Brown (Sandia National Laboratories)
%
function obj = runSimulation(obj)

% generate hkl

obj = generatehkl(obj, 'simulation');

% extract small stuff from the object (big stuff stays to conserve memory)

V = obj.crystal.volume;
v = obj.crystal.vectors;
s0 = obj.source.s0/norm(obj.source.s0);

mosaicity = reshape(obj.simulation.mosaicity, [3, 1]);
simulationNum = obj.simulation.simulationSize;
mosaicityDistribution = obj.simulation.mosaicityDistribution;
mosaicitySystem = obj.simulation.mosaicitySystem;
divergenceAngle = obj.simulation.beamDivergenceHalfAngle;
divergenceDistribution = obj.simulation.beamDivergenceDistribution;
guassianSpreadAngle = obj.simulation.gaussianSpreadHalfAngle;

mFlag = any(mosaicity > 0);
dFlag = divergenceAngle > 0;
gFlag = guassianSpreadAngle > 0;

% implement mosaicity

if mFlag
    v = mosaicitySim(mosaicity, simulationNum, mosaicityDistribution, ...
        mosaicitySystem, v);
end

% compute H

H = obj.simulation.hkl(:,1).*cross(v(2,:,:), v(3,:,:), 2)/V ...
    + obj.simulation.hkl(:,2).*cross(v(3,:,:), v(1,:,:), 2)/V + ...
    obj.simulation.hkl(:,3).*cross(v(1,:,:), v(2,:,:), 2)/V;
clear('v');

% implement beam divergence
% generate s0 divergence cone by rotating a random value determined by 
% divergenceHalfAngle about some orthogonal vector and then rotating the 
% result a random uniform amount around the original s0
% note: faster to repmat and use built-in dot and cross

if dFlag

    if strcmpi(divergenceDistribution, 'uniform')
        theta = 2*divergenceAngle*rand(1, 1, simulationNum) - ...
            divergenceAngle;
    else
        theta = divergenceAngle*randn(1, 1, simulationNum);
    end
    phi = 360*rand(1, 1, simulationNum);

    a = [1 1 -(s0(1)+s0(2))/s0(3)]; a = a/norm(a);
    if s0(3) == 0
        a = [0 0 1];
    end

    s0_orig = repmat(s0, 1, 1, simulationNum);
    s0 = s0.*cosd(theta) + cross(a,s0,2).*sind(theta) + ...
        a.*dot(a,s0,2).*(1-cosd(theta));
    clear('theta');
    s0 = s0.*cosd(phi) + cross(s0_orig,s0,2).*sind(phi) + ...
        s0_orig.*dot(s0_orig,s0,2).*(1-cosd(phi));
    clear('phi', 's0_orig')

end

% find lambda that satisfies elastic scattering condition - what
% value forces a unit vector solution to a unit vector input of the
% Laue equation? (pg 214 in Girolami) Each row corresponds to an hkl and 
% each page corresponds to a simulation instance.

a = sum(H.^2, 2);
b = sum(2*H.*s0, 2);
obj.simulation.lambdaSol = -b./a; % simplified quadratic formula for c = 0 and lambda ~= 0
clear('a', 'b')

% compute s

obj.simulation.s = s0 + H.*obj.simulation.lambdaSol;
clear('H', 's0')

% apply Guassian spread to s in the same manner as beam divergence was
% applied to s0

if gFlag

    a = ones(size(obj.simulation.s));
    a(:,3,:) = -(obj.simulation.s(:,1,:) + ...
        obj.simulation.s(:,2,:))./obj.simulation.s(:,3,:);
    ind = obj.simulation.s(:,3,:) == 0;
    if any(ind, 'all')
        % faster than linearizing s or using 3D find() indexing scheme:
        a = reshape(permute(a, [1 3 2]), [], 3);
        ind = reshape(ind, [], 1);
        a(repmat(ind,1,3)) = repmat([0 0 1],nnz(ind),1);
        clear('ind')
        a = permute(reshape(a, [], size(obj.simulation.s,3), 3), [1 3 2]);
    else
        clear('ind');
    end
    a = a./vecnorm(a,2,2);

    theta = guassianSpreadAngle*randn(1, 1, simulationNum);
    s_orig = obj.simulation.s;
    obj.simulation.s = obj.simulation.s.*cosd(theta) + ...
        cross(a,obj.simulation.s,2).*sind(theta) + ...
        a.*dot(a,obj.simulation.s,2).*(1-cosd(theta));
    clear('a', 'theta');
    phi = 360*rand(1, 1, simulationNum);
    if size(s_orig,3) ~= simulationNum
        s_orig = repmat(s_orig,1,1,simulationNum);
    end
    obj.simulation.s = obj.simulation.s.*cosd(phi) + ...
        cross(s_orig,obj.simulation.s,2).*sind(phi) + ...
        s_orig.*dot(s_orig,obj.simulation.s,2).*(1-cosd(phi));
    clear('phi', 's_orig');

end

% remove non-physical results, cast to 2D, and explicitly expand hkl
% this is eventually necessary and best performed at this stage because
% it delays expansion of hkl until after deletion of intermediate arrays 
% above, thereby reducing the number of O(simulationNum) variables held in 
% memory at once

if gFlag && (~dFlag && ~mFlag)
    obj.simulation.lambdaSol = repmat(obj.simulation.lambdaSol, ...
        simulationNum, 1);
end
obj.simulation.lambdaSol = reshape(obj.simulation.lambdaSol, [], 1);
ind = obj.simulation.lambdaSol <= 0;
obj.simulation.lambdaSol(ind) = [];
obj.simulation.s = reshape(permute(obj.simulation.s, [1 3 2]), [], 3);
obj.simulation.s(ind,:) = [];
if any([gFlag, dFlag, mFlag])
    obj.simulation.hkl = repmat(obj.simulation.hkl, simulationNum, 1);
end
obj.simulation.hkl(ind,:) = [];
clear('ind');

% find where spots hit the detector

if ~isempty(obj.simulation.s)
    obj = findSpotLocations(obj, 'simulation');
end

% find powder diffraction characteristics

if ~isempty(obj.simulation.hkl)
    obj = powderPredictor(obj, 'simulation');
    obj = applyPolarizationCorrection(obj, 'simulation');
else
    obj.simulation.I = [];
end
obj.simulation = rmfield(obj.simulation, 's');
obj.simulation = rmfield(obj.simulation, 'twoTheta');

% generate null image parameters
% pixels coordinates correspond to pixel centers

[xnum, ynum, xdist, ydist] = computeSimulationImageDimensions(obj);
xwidth = 2*xdist/xnum;
ywidth = 2*ydist/ynum;
x = linspace(-xdist+xwidth/2, xdist-xwidth/2, xnum);
y = linspace(-ydist+ywidth/2, ydist-ywidth/2, ynum);
Z = zeros(ynum, xnum);

% fill in image with non-zero data

if ~isempty(obj.simulation.I)

    % bin real data into image
    % really could be [x - xwidth/2, xdist] but using inf to avoid rounding
    % errors that could produce invalid index

    Xedges = [-inf, x(2:end) - xwidth/2, inf];
    Yedges = [-inf, y(2:end) - ywidth/2, inf];
    [~, ~, ~, binX, binY] = histcounts2(obj.simulation.xy(:,1), ...
        obj.simulation.xy(:,2), Xedges, Yedges);
    clear('Xedges', 'Yedges');

    % sum intensity in bins and then assign to image
    % don't love using splitapply here, but I don't think I have a choice -
    % and it's necessary to correctly assign the pixel bins for GA image
    % search (added time is pretty negligible, even for 1e6 pixel, 1e5 sim)

    [binXY, ~, ic] = unique([binX, binY], 'rows');
    clear('binX', 'binY');
    obj.simulation.hkl = ...
        splitapply(@(I,hkl)assignPixelSource(I,hkl), ...
        obj.simulation.I, obj.simulation.hkl, ic);
    obj.simulation.xy = [transpose(x(binXY(:,1))), transpose(y(binXY(:,2)))];
    obj.simulation.I = accumarray(ic, obj.simulation.I);
    clear('ic');
    if obj.simulation.normalizedSpotIntensity
        obj.simulation.I = obj.simulation.I / max(obj.simulation.I);
    end
    Z(sub2ind([ynum, xnum], binXY(:,2), binXY(:,1))) = obj.simulation.I;
    clear('binXY');

    % compute and store spot data

    % I want to use accumarray for the centroid calculation for speed, but
    % there's an issue with my implementation during parallel computations

    thresh = obj.simulation.centroidThreshold;
    [obj.simulation.hkl, ~, ic] = unique(obj.simulation.hkl, 'rows');
    % icExtended = repmat(ic, 2, 1);
    % cenFun = @(in)computeCentroidAccumarray(in,thresh);
    % obj.simulation.xy = [accumarray(icExtended, ...
    %     [obj.simulation.I; obj.simulation.xy(:,1)], [], cenFun), ...
    %     accumarray(icExtended, ...
    %     [obj.simulation.I; obj.simulation.xy(:,2)], [], cenFun)];
    obj.simulation.xy = splitapply(@(I,xy)computeCentroid(I,xy,thresh), ...
        obj.simulation.I, obj.simulation.xy, ic);
    obj.simulation.I = accumarray(ic, obj.simulation.I, [], ...
        @(I)computeIntensity(I, thresh));

    clear('ic', 'icExtended');

    badInd = obj.simulation.I/max(obj.simulation.I) < obj.simulation.reportThreshold;
    if obj.simulation.normalizedSpotIntensity
        obj.simulation.I = obj.simulation.I/max(obj.simulation.I);
    end
    obj.simulation.hkl(badInd,:) = [];
    obj.simulation.I(badInd) = [];
    obj.simulation.xy(badInd,:) = [];
    clear('badInd');

    [obj.simulation.I, ind] = sort(obj.simulation.I, 'descend');
    obj.simulation.hkl = obj.simulation.hkl(ind,:);
    obj.simulation.xy = obj.simulation.xy(ind,:);
    clear('ind');

end

obj.simulation.image = SMASH.ImageAnalysis.Image(x, y, Z);
obj.simulation.image.GraphicOptions.ColorMap = parula;
obj.simulation.image.GraphicOptions.AspectRatio = 'equal'; % square
obj.simulation.image.DataLabel = 'Intensity';
obj.simulation.current = true;
if ~isnumeric(obj.detector.image)
    obj.simulation.image.GraphicOptions.YDir = ...
        obj.detector.image.GraphicOptions.YDir; % match detector
end

end

function v = mosaicitySim(mosaicity, mosaicityPoints, ...
    mosaicityDistribution, mosaicitySystem, v)

% assumes degrees and rotates in randomized order
% mosaicity should be a column vector

% determine vectors and angles

if strcmpi(mosaicityDistribution, 'uniform') % 0 +/- mosaicity
    thetabase = 2*mosaicity.*rand(3, 1, mosaicityPoints) - mosaicity;
else
    thetabase = mosaicity.*randn(3, 1, mosaicityPoints); % normal
end

if strcmpi(mosaicitySystem, 'abc') || strcmpi(mosaicitySystem, 'crystal')
    kbase = v./vecnorm(v,2,2);
elseif strcmpi(mosaicitySystem, 'xyz') % xyz
    kbase = [1 0 0; 0 1 0; 0 0 1];
else
    error('Unrecognized mosacity system - run convertFromOld on obj');
end

% randomize rotation order

p = perms([1 2 3]);
randNum = rand(1, mosaicityPoints);
ind1 = randNum < 1/6;
ind2 = randNum >= 1/6 & randNum < 2/6;
ind3 = randNum >= 2/6 & randNum < 3/6;
ind4 = randNum >= 3/6 & randNum < 4/6;
ind5 = randNum >= 4/6 & randNum < 5/6;
ind6 = ~ind1 & ~ind2 & ~ind3 & ~ind4 & ~ind5;

k = nan(3,3,mosaicityPoints);
k(:,:,ind1) = repmat(kbase(p(1,:),:), 1, 1, nnz(ind1));
k(:,:,ind2) = repmat(kbase(p(2,:),:), 1, 1, nnz(ind2));
k(:,:,ind3) = repmat(kbase(p(3,:),:), 1, 1, nnz(ind3));
k(:,:,ind4) = repmat(kbase(p(4,:),:), 1, 1, nnz(ind4));
k(:,:,ind5) = repmat(kbase(p(5,:),:), 1, 1, nnz(ind5));
k(:,:,ind6) = repmat(kbase(p(6,:),:), 1, 1, nnz(ind6));

theta(:,:,ind1) = thetabase(p(1,:),:,ind1);
theta(:,:,ind2) = thetabase(p(2,:),:,ind2);
theta(:,:,ind3) = thetabase(p(3,:),:,ind3);
theta(:,:,ind4) = thetabase(p(4,:),:,ind4);
theta(:,:,ind5) = thetabase(p(5,:),:,ind5);
theta(:,:,ind6) = thetabase(p(6,:),:,ind6);

% implement rotation via Rodrigues

v = repmat(v, 1, 1, mosaicityPoints);
for ii = 1:3 % you either iterate or you write out three separate statements
    kii = repmat(k(ii,:,:), 3, 1, 1);
    v = v.*cosd(theta(ii,:,:)) + cross(kii,v,2).*sind(theta(ii,:,:)) + ...
        kii.*dot(kii,v,2).*(1-cosd(theta(ii,:,:)));
end

end

function I = computeIntensity(I, thresh)
I = mean(I(I > max(I)*thresh)); % to match removeBackground
end

function c = computeCentroidAccumarray(in, thresh)
len = numel(in)/2;
I = in(1:len); p = in(len+1:2*len);
I(I <= max(I)*thresh) = 0; % to match removeBackground
c = sum(I.*p)./sum(I);
end

function xy = computeCentroid(I, xy, thresh)
I(I <= max(I)*thresh) = 0;
xy = sum(I.*xy,1)./sum(I);
end

function hkl = assignPixelSource(I, hkl)
[~, ind] = max(I);
hkl = hkl(ind,:);
end

% function hkl = assignPixelSource(I, hkl)
% [hkl, ~, ic] = unique(hkl,'rows');
% if size(hkl,1) == 1
%     return
% end
% I = accumarray(ic, I);
% [~, ind] = max(I);
% hkl = hkl(ind,:);
% end


