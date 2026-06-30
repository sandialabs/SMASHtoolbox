% CALPOI - find points of interest for calibration
%
% This method finds points of interest for detector and crystal
% calibrations. It must be run after calCC unless applying a
% crystal calibration with the 'exact' poi method.
%
% Usage:
%   >> obj = calPOI(obj)
%
% created January, 2025 by Nathan Brown (Sandia National Laboratories)
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
            obj.calibration.poi = findRingPoints(obj.detector.image, ... % use raw image, not filtered
                obj.calibration.cc, obj.calibration.opts.minPointDist, ...
                obj.calibration.opts.maxPointNum, ...
                obj.calibration.opts.intCutoff);
        case 'manual'
            obj.calibration.poi = selectRingPoints(obj.detector.image, ax);
        case 'semiauto'
            error('Not yet functional')
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

peakPoints = nan(maxNum, 2, cc.NumObjects);

for ii = 1:cc.NumObjects
    ptsind = cc.PixelIdxList{ii};
    [ptsr, ptsc] = ind2sub(cc.ImageSize, ptsind);
    vals = im.Data(ptsind);
    sortVals = sort(vals);
    cutoffVal = sortVals(floor(cutoff*cc.NumPixels(ii)));
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
    peakPoints(1:maxNum,1,ii) = maxloc(:,1); % [pt, xy, region]
    peakPoints(1:maxNum,2,ii) = maxloc(:,2);
end

end

function poi = selectRingPoints(im, ax)

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
roi = manage(roi, 'target', ax, 'title', ...
    'Construct ROIs with increasing 2θ:', ...
    'figurename', 'Manual Ring POI Selection', ...
    'increment', true);
if ishandle(fig)
    close(fig);
end
maxNum = max(cellfun(@numel, {roi.Data}))/2;
poi = nan(maxNum, 2, numel(roi));
for ii = 1:numel(roi)
    if ~isempty(roi(ii).Data)
        poi(1:size(roi(ii).Data,1), :, ii) = roi(ii).Data;
    end
end

end
