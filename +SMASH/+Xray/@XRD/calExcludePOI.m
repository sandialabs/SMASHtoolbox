% Under construction
%
function obj = calExcludePOI(obj, varargin)

% input parsing

assert(~contains(obj.calibration.type, 'detector'), ...
    'Not compatible with detector calibration');
assert(~isempty(obj.calibration.poi), 'No POI to exlude');
imStr = 'detector';
lim = obj.detector.image.DataLim;
if nargin > 1
    if strcmpi(varargin{1}(1), 's')
        imStr = 'simulation';
        lim = obj.simulation.image.DataLim;
        if nargin > 2
            lim = varargin{2};
        end
    elseif strcmpi(varargin{1}(1), 'r')
        obj.calibration.poiExclude = false(size(obj.calibration.poi,1),1);
        return
    end
end
im = obj.(imStr).image;
assert(isa(im, 'SMASH.ImageAnalysis.Image'), 'Missing image');

% plot

poi = obj.calibration.poi;
poiExclude = obj.calibration.poiExclude;
h = view(im); clim(h.axes, lim);
hold(h.axes, 'on');
title(h.axes, 'Select points to exclude and then press Enter');
set(h.figure, 'windowstate', 'maximized');

% interactive selection

while ~all(poiExclude)
    plotInd = find(~poiExclude); % b/c I need it later to register selection
    ln = plot(h.axes, poi(plotInd,1), poi(plotInd,2), ...
        'r*', 'markersize', 5);
    try
        [x, y] = ginput(1);
    catch ME
        if strcmp(ME.identifier, 'MATLAB:ginput:FigureDeletionPause') % user cancel
            return
        else
            close(h.figure);
            throw(ME)
        end
    end
    if isempty(x) % user pressed enter
        close(h.figure);
        break
    end
    [~, ind] = min(vecnorm([x, y] - poi(plotInd,:), 2, 2));
    poiExclude(plotInd(ind)) = true;
    delete(ln);
end

obj.calibration.poiExclude = poiExclude;

end

