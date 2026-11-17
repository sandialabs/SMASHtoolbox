% CALCC - find connected components for calibrations
%
% This method finds connected components for both detector and crystal
% calibrations. It must be run after calFilter for detector calibrations
% and after calROI for crystal calibrations. calCC finds all connected
% components for crystal calibrations and just one for detector
% calibrations, based on the user input point.
%
% Usage:
%   >> obj = calCC(obj) for crystal calibrations
%   >> obj = calCC(obj, [x y]) for detector calibrations, where [x y]
%       is an input point that guides the cc finder
%
% created October, 2026 by Nathan Brown (Sandia National Laboratories)
%
function obj = calCC(obj, varargin)

%% Input Parsing

im = obj.detector.image;
assert(~isnumeric(im), 'No detector image')
if ~contains(obj.calibration.type, 'detector')
    assert(~isempty(obj.calibration.roi), 'No ROI detected');
else
    assert(nargin > 1, 'Missing [x y] pixel input')
    loc = varargin{1};
    assert(numel(loc) == 2, 'Invalid [x y] input')
    assert(isa(obj.calibration.filterSubtract,'SMASH.ImageAnalysis.Image'), ...
        'Must first run calFilter');
end
if isfield(obj.calibration, 'poiIntensity')
    obj.calibration = rmfield(obj.calibration,'poiIntensity');
end

%% code

if contains(obj.calibration.type,'detector')

    % filter the image according to the cutoff computed from the user
    % selection

    cutoff = lookup(obj.calibration.filterSubtract,loc(1),loc(2)) * ...
        obj.calibration.opts.threshFrac;
    ind = obj.calibration.filterSubtract.Data < cutoff;
    im = replace(obj.detector.image,0,ind);

    % find the specific connected component region selected by the user

    [~,cc] = ccFilter(im,obj.calibration.opts.minRegSize,4);
    smallestDist = inf;
    for ii = 1:cc.NumObjects
        [rInd, cInd] = ind2sub(cc.ImageSize, cc.PixelIdxList{ii});
        dist = min(vecnorm(loc - [im.Grid1(cInd)' im.Grid2(rInd)],2,2));
        if dist < smallestDist
            smallestDist = dist;
            ccInd = ii;
        end
    end

    newCC = obj.calibration.cc;
    if isempty(newCC)
        newCC = cc;
        newCC.NumObjects = 1;
        newCC.NumPixels = cc.NumPixels(ccInd);
        newCC.PixelIdxList = cc.PixelIdxList(ccInd);
    else
        newCC.NumObjects = newCC.NumObjects + 1;
        newCC.NumPixels(end+1) = cc.NumPixels(ccInd);
        newCC.PixelIdxList(end+1) = cc.PixelIdxList(ccInd);
    end
    obj.calibration.cc = newCC;

else

    % iteratively background and cc filter at each roi point to find
    % the associated cc region

    obj.calibration.poi = [];
    roi = obj.calibration.roi;
    threshFrac = obj.calibration.opts.threshFrac;
    filterBounds = obj.calibration.opts.filterBounds;
    obj.calibration.cc = findCC(obj.detector.image, roi, threshFrac, ...
        filterBounds, 'crystal');
end

end
