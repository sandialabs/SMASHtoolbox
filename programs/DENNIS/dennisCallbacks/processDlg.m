function processDlg(src, event, mainFigure)

%% build cb

[cb, ~, ex] = createCB(src, mfilename);
if ex
    return
end
name = 'Detector Image Processing';

% roi selections

h = addMessage(cb);
h.Text = 'ROI Selections';
h.FontWeight = 'Bold';
h.FontSize = 20;

bw = 8;
bNames = {'Crop', 'Background', 'Mask', 'Reverse Mask', 'Scale'};
for ii = 1:numel(bNames)
    newRow(cb);
    h = addButton(cb, bw);
    h.Text = bNames{ii};
    h.Tag = h.Text;
    h = addButton(cb, 5);
    h.Text = 'Reset';
    h.Tag = [bNames{ii},'Reset'];
end

setGap(cb, [10 0]);
newRow(cb);
h = addCheckbox(cb, 6);
h.Text = ' Use Circle?';
h.Tag = 'Circle';
h = addCheckbox(cb, 7);
h.Text = ' Use Ellipse?';
h.Tag = 'Ellipse';
setGap(cb, [10 10]);

% contour limits

newRow(cb);
h = addMessage(cb);
h.Text = 'Contour Limits';
h.FontWeight = 'Bold';
h.FontSize = 20;

setGap(cb, [10 0]);
newRow(cb);
h = [addEdit(cb, 4) addEdit(cb, 4)];
h(1).Text = 'Min';
h(2).Tag = 'ContourEdit';
h(3).Text = 'Max';
h(4).Tag = h(2).Tag;
h = addButton(cb, 5);
h.Text = 'Reset';
h.Tag = 'ContourReset';
setGap(cb, [10 10]);

% connected component filtering

newRow(cb);
h = addMessage(cb);
h.Text = 'Conn Comp Filter';
h.FontWeight = 'Bold';
h.FontSize = 20;

setGap(cb, [10 0]);
newRow(cb);
h = addListbox(cb, 6, 2);
h(1).Text = 'Conn';
h(2).Items = {'4', '8'};
h(2).Tag = 'ConnList';
h = addEdit(cb, 3);
h(1).Text = 'Size';
h(2).Tag = 'ConnEdit';
setGap(cb, [10 10]);

newRow(cb);
h = addButton(cb, 5);
h.Text = 'Filter';
h.Tag = 'ConnButton';
h = addButton(cb, 5);
h.Text = 'Reset';
h.Tag = 'ConnReset';

% smoothing

newRow(cb);
h = addMessage(cb);
h.Text = 'Smooth';
h.FontWeight = 'Bold';
h.FontSize = 20;

setGap(cb, [10 0]);
newRow(cb);
h = addListbox(cb, 6, 2);
h(1).Text = 'Type';
h(2).Items = {'Mean', 'Median'};
h(2).Tag = 'SmoothList';
h = addEdit(cb, 3);
h(1).Text = 'Size';
h(2).Tag = 'SmoothEdit';
setGap(cb, [10 10]);

newRow(cb);
h = addButton(cb, 5);
h.Text = 'Filter';
h.Tag = 'SmoothButton';
h = addButton(cb, 5);
h.Text = 'Reset';
h.Tag = 'SmoothReset';

% bandpass

newRow(cb);
h = addMessage(cb);
h.Text = 'Bandpass';
h.FontWeight = 'Bold';
h.FontSize = 20;

setGap(cb, [10 0]);
newRow(cb);
h = addListbox(cb, 6, 4);
h(1).Text = 'Type';
h(2).Items = {'Ideal', 'Gaussian', 'Butterworth', 'Chebyshev'};
h(2).Tag = 'BandList';
h = [addEdit(cb, 3), addEdit(cb, 3), addEdit(cb, 3)];
h(1).Text = 'Min';
h(3).Text = 'Max';
h(5).Text = 'Order';
h(2).Tag = 'BandEdit';
h(4).Tag = h(2).Tag;
h(6).Tag = h(2).Tag;
setGap(cb, [10 10]);

newRow(cb);
h = addButton(cb, 5);
h.Text = 'Filter';
h.Tag = 'BandButton';
h = addButton(cb, 5);
h.Text = 'Reset';
h.Tag = 'BandReset';

% saving

newRow(cb);
h = addMessage(cb);
h.Text = 'Save';
h.FontWeight = 'Bold';
h.FontSize = 20;

newRow(cb);
h = addButton(cb, 5);
h.Text = 'Save';
h.Tag = h.Text;
h = addButton(cb, 5);
h.Text = 'Revert';
h.Tag = h.Text;
h = addButton(cb, 5);
h.Text = 'Reset';
h.Tag = h.Text;

%% build combined

[new, fig, ax] = createCombined(mainFigure, cb, name);
set(fig, 'units', 'normalized');
set(fig, 'outerposition', [0.1 0.1 .9 .9]);
movegui(fig, 'center');
set(fig, 'units', 'pixels');

% recover original DENNIS handle names
% Dolan tags and then names after combining in his examples

h_crop = findobj(new, 'Tag', 'Crop');
h_cropReset = findobj(new, 'Tag', 'CropReset');
h_back = findobj(new, 'Tag', 'Background');
h_backReset = findobj(new, 'Tag', 'BackgroundReset');
h_mask = findobj(new, 'Tag', 'Mask');
h_maskReset = findobj(new, 'Tag', 'MaskReset');
h_reverseMask = findobj(new, 'Tag', 'Reverse Mask');
h_reverseMaskReset = findobj(new, 'Tag', 'Reverse MaskReset');
h_scale = findobj(new, 'Tag', 'Scale');
h_scaleReset = findobj(new, 'Tag', 'ScaleReset');
h_circle = findobj(new, 'Tag', 'Circle');
h_ellipse = findobj(new, 'Tag', 'Ellipse'); 
h_limEdit = findobj(new, 'Tag', 'ContourEdit');
h_limReset = findobj(new, 'Tag', 'ContourReset');
h_ccList = findobj(new, 'Tag', 'ConnList');
h_ccEdit = findobj(new, 'Tag', 'ConnEdit');
h_ccButton = findobj(new, 'Tag', 'ConnButton');
h_ccReset = findobj(new, 'Tag', 'ConnReset');
h_smoothList = findobj(new, 'Tag', 'SmoothList');
h_smoothEdit = findobj(new, 'Tag', 'SmoothEdit');
h_smoothButton = findobj(new, 'Tag', 'SmoothButton');
h_smoothReset = findobj(new, 'Tag', 'SmoothReset');
h_bandFilterList = findobj(new, 'Tag', 'BandList');
h_bandFilterEdit = findobj(new, 'Tag', 'BandEdit');
h_bandFilterButton = findobj(new, 'Tag', 'BandButton');
h_bandFilterReset = findobj(new, 'Tag', 'BandReset');
h_save = findobj(new, 'Tag', 'Save');
h_revert = findobj(new, 'Tag', 'Revert');
h_reset = findobj(new, 'Tag', 'Reset');

%% set defaults
% Dolan recommends doing this after creating combined

set(ax, 'FontSize', 16);
hold(ax, 'on')

set(h_limEdit(1), 'Tag', 'clim1');
set(h_limEdit(2), 'Tag', 'clim2');

set(findobj(new, 'Tag', 'ConnEdit'), 'Value', num2str(20));
set(findobj(new, 'Tag', 'SmoothEdit'), 'Value', num2str(5));
set(h_bandFilterEdit(1), 'Value', num2str(0));
set(h_bandFilterEdit(2), 'Value', num2str(1));
set(h_bandFilterEdit(3), 'Value', num2str(1));

%% set callbacks
% Dolan recommends doing this after creating combined

set(h_crop, 'ButtonPushedFcn', {@processCrop, mainFigure});
set(h_cropReset, 'ButtonPushedFcn', {@processCropReset, mainFigure});
set(h_back, 'ButtonPushedFcn', {@processBack, mainFigure, h_circle, h_ellipse});
set(h_backReset, 'ButtonPushedFcn', {@processBackReset, mainFigure});
set(h_mask, 'ButtonPushedFcn', {@processMask, mainFigure, h_circle, h_ellipse});
set(h_maskReset, 'ButtonPushedFcn', {@processMaskReset, mainFigure});
set(h_reverseMask, 'ButtonPushedFcn', {@processReverseMask, mainFigure, h_circle, h_ellipse});
set(h_reverseMaskReset, 'ButtonPushedFcn', {@processReverseMaskReset, mainFigure});
set(h_scale, 'ButtonPushedFcn', {@processScale, mainFigure, h_circle});
set(h_scaleReset, 'ButtonPushedFcn', {@processScaleReset, mainFigure});
set(h_circle, 'ValueChangedFcn', {@processCircle, h_circle, h_ellipse});
set(h_ellipse, 'ValueChangedFcn', {@processCircle, h_circle, h_ellipse});
set(h_limEdit, 'ValueChangedFcn', {@processLimEdit, mainFigure, h_limEdit});
set(h_limReset, 'ButtonPushedFcn', {@processLimReset, mainFigure, h_limEdit});
set(h_ccButton, 'ButtonPushedFcn', {@processCC, mainFigure, h_ccList, h_ccEdit});
set(h_ccReset, 'ButtonPushedFcn', {@processCCReset, mainFigure});
set(h_smoothButton, 'ButtonPushedFcn', {@processSmooth, mainFigure, ...
    h_smoothList, h_smoothEdit});
set(h_smoothReset, 'ButtonPushedFcn', {@processSmoothReset, mainFigure});
set(h_bandFilterButton, 'ButtonPushedFcn', {@processFilter, mainFigure, ...
    h_bandFilterList, h_bandFilterEdit});
set(h_bandFilterReset, 'ButtonPushedFcn', {@processFilterReset, mainFigure});
set(h_save, 'ButtonPushedFcn', {@processSave, mainFigure});
set(h_revert, 'ButtonPushedFcn', {@processRevert, mainFigure});
set(h_reset, 'ButtonPushedFcn', {@processReset, mainFigure});

set(fig, 'WindowKeyPressFcn', @(src, event)uiresume(src)); % paired with uiwait in drawCircle

% re-save to app data so you have Tags

setappdata(mainFigure, 'processDlg', fig)

% check for image and then plot

obj = get(mainFigure, 'UserData');
if isnumeric(obj.detector.image)
    importDetectorImage(mainFigure);
    obj = get(mainFigure, 'UserData');
    if isnumeric(obj.detector.image)
        close(fig)
    end
end
updatePlotPredictionAnalysis(mainFigure, 'imageProcessingDisplay');

% check if we can use the circle ROI

if license('test', 'image_toolbox')
    set(h_circle, 'Value', true)
end

% show figure

figure(fig);

end

function processCrop(src, event, mainFigure)
obj = get(mainFigure, 'UserData');
ax = get(ancestor(src, 'figure'), 'CurrentAxes');
obj = processImage(obj, 'crop', ax);
set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure);
xlim(ax, [min(obj.detector.image.Grid1) max(obj.detector.image.Grid1)]);
ylim(ax, [min(obj.detector.image.Grid2) max(obj.detector.image.Grid2)]);
end

function processCropReset(src, event, mainFigure)
obj = get(mainFigure, 'UserData');
ax = get(ancestor(src, 'figure'), 'CurrentAxes');
obj = processImage(obj, 'cropReset');
set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure);
xlim(ax, [min(obj.detector.image.Grid1) max(obj.detector.image.Grid1)]);
ylim(ax, [min(obj.detector.image.Grid2) max(obj.detector.image.Grid2)]);
end

function processBack(src, event, mainFigure, h_circle, h_ellipse)
obj = get(mainFigure, 'UserData');
ax = get(ancestor(src, 'figure'), 'CurrentAxes');
if get(h_circle, 'Value')
    ind = drawCircle(ax);
    obj = processImage(obj, 'background', ind);
elseif get(h_ellipse, 'Value')
    ind = drawCircle(ax, 'ellipse');
    obj = processImage(obj, 'background', ind);
else
    obj = processImage(obj, 'background', ax);
end
set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure);
end

function processBackReset(src, event, mainFigure)
obj = get(mainFigure, 'UserData');
obj = processImage(obj, 'backgroundReset');
set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure);
end

function processMask(src, event, mainFigure, h_circle, h_ellipse)
obj = get(mainFigure, 'UserData');
ax = get(ancestor(src, 'figure'), 'CurrentAxes');
if get(h_circle, 'Value')
    ind = drawCircle(ax);
    obj = processImage(obj, 'mask', ind);
elseif get(h_ellipse, 'Value')
    ind = drawCircle(ax, 'ellipse');
    obj = processImage(obj, 'mask', ind);
else
    obj = processImage(obj, 'mask', ax);
end
set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure);
end

function processMaskReset(src, event, mainFigure)
obj = get(mainFigure, 'UserData');
obj = processImage(obj, 'maskReset');
set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure);
end

function processReverseMask(src, event, mainFigure, h_circle, h_ellipse)
obj = get(mainFigure, 'UserData');
ax = get(ancestor(src, 'figure'), 'CurrentAxes');
if get(h_circle, 'Value')
    ind = drawCircle(ax);
    obj = processImage(obj, 'mask', ind, true);
elseif get(h_ellipse, 'Value')
    ind = drawCircle(ax, 'ellipse');
    obj = processImage(obj, 'mask', ind);
else
    obj = processImage(obj, 'mask', ax, true);
end
set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure);
end

function processReverseMaskReset(src, event, mainFigure)
obj = get(mainFigure, 'UserData');
obj = processImage(obj, 'reverseMaskReset');
set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure);
end

function processScale(src, event, mainFigure, h_circle)
obj = get(mainFigure, 'UserData');
ax = get(ancestor(src, 'figure'), 'CurrentAxes');
if get(h_circle, 'Value')
    [~, diam] = drawCircle(ax);
    obj = processImage(obj, 'scale', diam);
else
    obj = processImage(obj, 'scale', ax);
end
set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure);
end

function processScaleReset(src, event, mainFigure)
obj = get(mainFigure, 'UserData');
obj = processImage(obj, 'scaleReset');
set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure);
end

function processCircle(src, event, h_circle, h_ellipse)

% handle set logic

if contains(get(src,'Text'), 'Circle')
    set(h_ellipse, 'Value', 0);
else
    set(h_circle, 'Value', 0);
end

% check that we can set desired

if ~license('test', 'image_toolbox') && get(src, 'Value')
    set(src, 'Value', false);
    errordlg(['Must have Image Processing Toolbox to ' ...
        'use circle ROIs']);
end

end

function processLimEdit(src, event, mainFigure, h_limEdit)
newVal = editExtract(h_limEdit);
obj = get(mainFigure, 'UserData');
if any(isnan(newVal))
    newVal = obj.detector.image.DataLim;
    if ischar(newVal)
        newVal = [min(min(obj.detector.image.Data)), ...
            max(max(obj.detector.image.Data))];
    end
end
obj = processImage(obj, 'contourLimits', newVal);
set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure, 'imageProcessingDisplay');
end

function processLimReset(src, event, mainFigure, h_limEdit)
obj = get(mainFigure, 'UserData');
obj = processImage(obj, 'contourLimitsReset');
set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure, 'imageProcessingDisplay');
end

function processCC(src, event, mainFigure, h_ccList, h_ccEdit)
conn = str2double(get(h_ccList,'Value'));
P = editExtract(h_ccEdit);
obj = get(mainFigure, 'UserData');
obj = processImage(obj, 'ccFilter', P, conn);
set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure);
end

function processCCReset(src, event, mainFigure)
obj = get(mainFigure, 'UserData');
obj = processImage(obj, 'ccFilterReset');
set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure);
end

function processSmooth(src, event, mainFigure, h_smoothList, h_smoothEdit)
smoothType = get(h_smoothList,'Value');
smoothValue = editExtract(h_smoothEdit);
if ~isnan(smoothValue)
    obj = get(mainFigure, 'UserData');
    obj = processImage(obj, 'smooth', smoothType, smoothValue);
    set(mainFigure, 'UserData', obj);
    updatePlotPredictionAnalysis(mainFigure);
else
    errordlg('Bad smoothing inputs', 'Bad smoothing inputs')
end
end

function processSmoothReset(src, event, mainFigure)
obj = get(mainFigure, 'UserData');
obj = processImage(obj, 'smoothReset');
set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure);
end

function processFilter(src, event, mainFigure, h_filterList, h_filterEdit)
filterType = get(h_filterList, 'Value');
filterRange = editExtract(h_filterEdit);
if ~any(isnan(filterRange(1:2)))
    if isnan(filterRange(3))
        filterRange(3) = 1;
    end
    obj = get(mainFigure, 'UserData');
    obj = processImage(obj, 'bandpassfilter', filterRange(1:2), filterType, ...
        filterRange(3));
    set(mainFigure, 'UserData', obj);
    updatePlotPredictionAnalysis(mainFigure);
else
    errordlg('Bad filter inputs', 'Bad filter inputs')
end
end

function processFilterReset(src, event, mainFigure)
obj = get(mainFigure, 'UserData');
obj = processImage(obj, 'filterReset');
set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure);
end

function processSave(src, event, mainFigure)
obj = get(mainFigure, 'UserData');
obj = processImage(obj, 'save');
set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure);
end

function processRevert(src, event, mainFigure)
obj = get(mainFigure, 'UserData');
obj = processImage(obj, 'revertToSave');
set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure);
end

function processReset(src, event, mainFigure)
obj = get(mainFigure, 'UserData');
obj = processImage(obj, 'revertToOriginal');
set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure);
end
