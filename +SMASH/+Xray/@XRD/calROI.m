% CALROI - select regions of interest for calibrations
%
% This method finds SMASH ROIs for crystal calibrations.
%
% Usage:
%   >> obj = calROI(obj)
%   >> obj = calROI(obj, target)
%
% created January, 2025 by Nathan Brown (Sandia National Laboratories)
%
function obj = calROI(obj, varargin)

% parse inputs

assert(contains(obj.calibration.type,'crystal'), ...
    'Only valid for crystal calibrations');
assert(~isnumeric(obj.detector.image), 'No detector image')

fig = nan; ax = nan;
if nargin > 1 && ishandle(varargin{1})
    ax = varargin{1};
end

obj.calibration.cc = [];
obj.calibration.poi = [];
if isfield(obj.calibration, 'poiIntensity')
    obj.calibration = rmfield(obj.calibration,'poiIntensity');
end

% user ROI selection

switch obj.calibration.opts.roiSelect
    case 'auto'
        roi = autoSpotFind(obj, obj.calibration.opts.roiNum);
    case 'manual'
        if ~ishandle(ax)
            msg = 'Select spots';
            [fig, ax] = showImage(obj.detector.image, msg);
        end
        roi = SMASH.ROI.selectROI({'points','open'}, ax);
        obj.calibration.opts.roiNum = size(roi.Data,1);
end

obj.calibration.roi = roi.Data;

if ishandle(fig)
    close(fig)
end

end