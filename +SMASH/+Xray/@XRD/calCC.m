% CALCC - find connected component regions for calibration
%
% This method finds connected component regions for detector and crystal
% calibrations. It must be run after calThresh for 
% detectorAuto, after background removal for detectorManual, and after 
% calROI for crystal.
%
% Usage:
%   >> obj = calCC(obj)
%
% created January, 2025 by Nathan Brown (Sandia National Laboratories)
%
function obj = calCC(obj)

% input parsing

im = obj.detector.image;
assert(~isnumeric(im), 'No detector image')
if ~strcmp(obj.calibration.type, 'detectorManual')
    assert(~isempty(obj.calibration.roi), 'No ROI detected');
end

obj.calibration.poi = [];
if isfield(obj.calibration, 'poiIntensity')
    obj.calibration = rmfield(obj.calibration,'poiIntensity');
end

% code

switch obj.calibration.type
    case 'detectorAuto'

        % iteratively background and cc filter at each roi point to find
        % the associated cc region

        im = obj.calibration.processedImage;
        assert(~isnumeric(im), 'No filtered detector image')
        roi = obj.calibration.roi;
        thresh = obj.calibration.opts.threshold;
        regSize = obj.calibration.opts.minRegSize;
        obj.calibration.cc = findCC(im, roi, thresh, 'none', 'detector', ...
            regSize);

    case 'detectorManual'

        % apply global cc to image based on region size

        if ~isnumeric(obj.calibration.processedImage)
            im = obj.calibration.processedImage;
        end
        [~, obj.calibration.cc] = ccFilter(im, ...
            obj.calibration.opts.minRegSize, 4);

    case 'crystal'

        % iteratively background and cc filter at each roi point to find
        % the associated cc region

        roi = obj.calibration.roi;
        threshFrac = obj.calibration.opts.threshFrac;
        filterBounds = obj.calibration.opts.filterBounds;
        obj.calibration.cc = findCC(obj.detector.image, roi, threshFrac, ...
            filterBounds, 'crystal');

end

end
