% CALROI - select regions of interest for calibrations
%
% This method finds SMASH ROIs for detector and crystal calibrations.
%
% Usage:
%   >> obj = calROI(obj)
%   >> obj = calROI(obj, target)
%
% created January, 2025 by Nathan Brown (Sandia National Laboratories)
%
function obj = calROI(obj, varargin)

% parse inputs

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

switch obj.calibration.type
    case 'detectorAuto'
        if ~ishandle(ax)
            msg = ['Select consecutive rings along a representative', ...
                ' slice, starting with the smallest 2θ'];
            [fig, ax] = showImage(obj.detector.image, msg);
        end
        roi = SMASH.ROI.selectROI({'points','connected'}, ax);
    case 'detectorManual'
        warning('No roi selection required for detectorManual');
        return
    case 'crystal'
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
end

obj.calibration.roi = roi.Data;

if ishandle(fig)
    close(fig)
end

end