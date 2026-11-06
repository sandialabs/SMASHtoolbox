% CALPOI - find points of interest for calibration
%
% This method finds points of interest for detector and crystal
% calibrations. It must be run after calCC unless applying a
% crystal calibration with the 'exact' poi method or applying a detector
% calibration with the 'manual' poi type. For auto detector calibrations, 
% it only finds the poi associated with the last connected component
% region and automatically seeks to combine ring components based on conic
% section fits.
%
% Usage:
%   >> obj = calPOI(obj)
%   >> obj = calPOI(obj, ax) to specify axis for manual detector
%   >> obj = calPOI(obj, poi) to directly specify poi
%
% created October, 2025 by Nathan Brown (Sandia National Laboratories)
%
function obj = calPOI(obj, varargin)

% input parsing

ax = nan;
if nargin > 1 && isscalar(varargin{1}) && ishandle(varargin{1})
    ax = varargin{1};
elseif nargin > 1 && isnumeric(varargin{1})
    obj.calibration.poi = varargin{1};
    return
end

if ~strcmp(obj.calibration.opts.poiType, 'manual')
    if ~strcmp(obj.calibration.opts.poiType, 'exact')
        assert(~isempty(obj.calibration.cc), 'No connected components')
    else
        assert(~isempty(obj.calibration.roi), 'No ROI')
    end
end

if isfield(obj.calibration, 'poiIntensity')
    obj.calibration = rmfield(obj.calibration,'poiIntensity');
end

% code

if contains(obj.calibration.type, 'detector')
    switch obj.calibration.opts.poiType
        case 'auto'
            newPOI = findRingPoints(obj.detector.image, ...
                obj.calibration.cc, obj.calibration.opts.minPointDist, ...
                obj.calibration.opts.maxPointNum, ...
                obj.calibration.opts.intCutoff);
            obj = combinePOI(obj, newPOI);
        case 'manual'
            obj.calibration.poi = selectRingPoints(obj.detector.image, ...
                obj.calibration.poi, obj.calibration.opts.maxPointNum, ax);
            obj.calibration.poiFitResidual = [];
            obj.calibration.cc = [];
    end
else
    [poi, poiIntensity] = findCrystalPOI(obj.detector.image, ...
        obj.calibration.roi, obj.calibration.cc, ...
        obj.calibration.opts.poiType);
    if ~strcmp(obj.calibration.opts.poiType, 'exact')
        scaleX = obj.detector.image.Grid1(end) - obj.detector.image.Grid1(1);
        scaleY = obj.detector.image.Grid2(end) - obj.detector.image.Grid2(1);
        [poi, ia, ic] = uniquetol(poi, 0.01, 'ByRows', true, ...
            'DataScale', [scaleX, scaleY]);
        poiIntensity = poiIntensity(ia);
        % obj.calibration.roi = obj.calibration.roi(ia);
        % obj.calibration.opts.roiNum = numel(ia);
        d = numel(ic) - numel(ia);
        if d ~= 0
            fprintf('Removed %d redundant POI\n', d);
        end
    end
    obj.calibration.poi = poi;
    obj.calibration.poiIntensity = poiIntensity;
end

end

function peakPoints = findRingPoints(im, cc, minPointDist, maxNum, cutoff)

% start with brightest spot in region and then loop through and iteratively
% find next-brightest spot that is min distance away from all other spots
% in region, until either the max number of spots is found or the
% next-brightest spot is below the intensity threshold

peakPoints = nan(maxNum, 2);
ptsind = cc.PixelIdxList{end};
[ptsr, ptsc] = ind2sub(cc.ImageSize, ptsind);
vals = im.Data(ptsind);
sortVals = sort(vals);
cutoffVal = sortVals(floor(cutoff*cc.NumPixels(end)));
vals(vals < cutoffVal) = 0;
maxloc = nan(maxNum,2);
[~, idxMax] = max(vals);
maxloc(1,:) = [im.Grid1(ptsc(idxMax)), im.Grid2(ptsr(idxMax))];
idxClose = sqrt((ptsr(idxMax) - ptsr).^2 + ...
    (ptsc(idxMax) - ptsc).^2) < minPointDist;
vals(idxClose) = 0;
jj = 2;
while any(vals) && jj <= maxNum
    [~, idxMax] = max(vals);
    maxloc(jj,:) = [im.Grid1(ptsc(idxMax)), im.Grid2(ptsr(idxMax))];
    idxClose = sqrt((ptsr(idxMax) - ptsr).^2 + ...
        (ptsc(idxMax) - ptsc).^2) < minPointDist;
    vals(idxClose) = 0;
    jj = jj + 1;
end
peakPoints(1:maxNum,:) = maxloc; % [pt, xy, region]

end

function poi = selectRingPoints(im, poi, maxNum, ax)

fig = nan;
if ~ishandle(ax)
    h = view(im);
    ax = h.axes;
    fig = h.figure;
    set(fig, 'windowstate', 'maximized')
    title(ax, '');
end
roi = SMASH.ROI.Points('open');
roi.Name = 'Diffraction Ring';
if ~isempty(poi) % for some reason size([],3) = 1 ...
    roi = repmat(roi, 1, size(poi,3));
    for ii = 1:size(poi,3)
        tab = poi(:,:,ii);
        roi(ii) = define(roi(ii), tab(~isnan(tab(:,1)),:));
    end
end
roi = manage(roi, 'target', ax, 'title', ...
    'Construct ROIs in increasing 2θ order:', ...
    'figurename', 'Manual Ring POI Selection', ...
    'increment', true);
if ishandle(fig)
    close(fig);
end
poi = nan(maxNum, 2, numel(roi));
badInd = [];
for ii = 1:numel(roi)
    if ~isempty(roi(ii).Data)
        poi(1:min(size(roi(ii).Data,1),maxNum), :, ii) = roi(ii).Data;
    else
        badInd = [badInd, ii];
    end
end
poi(:,:,badInd) = [];
if isempty(poi)
    poi = [];
end

end

function obj = combinePOI(obj, newPOI)

% compare combined residual to existing residuals and combine cc's as
% needed

poi = obj.calibration.poi;
resComp = obj.calibration.poiFitResidual;
ind = numel(resComp)+1;
for ii = 1:numel(resComp)
    newRes = conicSectionResidual([poi(:,:,ii); newPOI]);
    if isfinite(resComp(ii)) && newRes <= resComp(ii)*obj.calibration.opts.fitResidualTolerance
        cc = obj.calibration.cc;
        cc.NumPixels(ii) = cc.NumPixels(ii) + cc.NumPixels(end);
        cc.PixelIdxList(ii) = {[cc.PixelIdxList{ii}; cc.PixelIdxList{end}]};
        cc.NumPixels(end) = [];
        cc.PixelIdxList(end) = [];
        cc.NumObjects = cc.NumObjects - 1;
        obj.calibration.cc = cc;
        ccIn = cc;
        ccIn.NumPixels = ccIn.NumPixels(ii);
        ccIn.PixelIdxList = ccIn.PixelIdxList(ii);
        newPOI = findRingPoints(obj.detector.image, ...
                ccIn, obj.calibration.opts.minPointDist, ...
                obj.calibration.opts.maxPointNum, ...
                obj.calibration.opts.intCutoff);
        ind = ii;
        break
    end
end
obj.calibration.poi(:,:,ind) = newPOI;
obj.calibration.poiFitResidual(ind) = conicSectionResidual(newPOI);
end

function res = conicSectionResidual(pts)

pts(isnan(pts(:,1)),:) = [];
M = [pts(:,1).^2, prod(pts,2), pts(:,2).^2, pts, ones(size(pts,1),1)];
[~, ~, V] = svd(M,0);
c = V(:,end) / norm(V(:,end));
if c(2)^2 - 4*c(1)*c(3) > 0 % hyperbola
    c = fitEllipse(pts);
    if ~isnumeric(c)
        res = inf;
        return
    end
end
c = c';

% use geometric residual to provide some intuition for deciding how to use
% result
f = c(1)*pts(:,1).^2 + c(2)*prod(pts,2) + ...
    c(3)*pts(:,2).^2 + sum(c(4:5).*pts,2) +  c(6);
fx = 2*c(1)*pts(:,1) + c(2)*pts(:,2) + c(4);
fy = c(2)*pts(:,1) + 2*c(3)*pts(:,2) + c(5);
denom = sqrt(fx.^2 + fy.^2);
denom(denom < 1e-10) = 1e-10;
res = median(abs(f) ./ denom);

end

function c = fitEllipse(pts)

D1 = [pts(:,1).^2, prod(pts,2), pts(:,2).^2];
D2 = [pts(:,1).^2, pts(:,2), ones(size(pts,1),1)];
S1 = D1' * D1;
S2 = D1' * D2;
S3 = D2' * D2;
T = -S3 \ S2';
M = S1 + S2*T;

C1 = [0  0  2; 0 -1  0; 2  0  0];
[V,~] = eig(M, C1);

found = false;
for k = 1:size(V,2)
    a1 = real(V(:,k));
    ellipseCondition = 4*a1(1)*a1(3) - a1(2)^2;
    if ellipseCondition > 0
        found = true;
        break;
    end
end
if ~found
    c = 'failed';
    return
end

a1 = a1 / sqrt(ellipseCondition);
a2 = T * a1;
c = [a1; a2];
c = c / norm(c);

end