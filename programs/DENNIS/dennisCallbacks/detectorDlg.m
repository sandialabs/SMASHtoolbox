function detectorDlg(src, event)

%% build cb

[cb, mainFigure, ex] = createCB(src, mfilename);
if ex
    return
end
setName(cb, 'Detector Parameters');

% shape and size

h_shapeLabel = addMessage(cb);
h_shapeLabel.Text = 'Shape';
h_shapeLabel.FontWeight = 'Bold';
h_shapeLabel.FontSize = 20;
setGap(cb, [10 0]);

newRow(cb);
h_shapeRadio = addRadio(cb, [5 5], 2, 'h', 'off');
h_shapeRadio(1).Text = 'Rectangle';
h_shapeRadio(2).Text = 'Circle';

newRow(cb);
h_shapeEdit = [addEdit(cb, 5) addEdit(cb, 5)];
h_shapeEdit(1).Text = 'Height';
h_shapeEdit(3).Text = 'Width';
setGap(cb, [0 10]);
h_shapeText = addMessage(cb, 2);
h_shapeText.Text = 'mm';
setGap(cb, [10 10]);

newRow(cb);
h_shapeSliderLabel = addMessage(cb);
h_shapeSliderLabel.Text = 'Transparency';
setGap(cb, [10 0]);
newRow(cb);
h_shapeSlider = [addSlider(cb, [0 10]), addEdit(cb, [0 3])];
h_shapeSlider(3) = [];
setGap(cb, [10 10]);

newRow(cb);
h_shapeButton = [addButton(cb, 5), addButton(cb, 5), addButton(cb, 5)];
h_shapeButton(1).Text = 'Load';
h_shapeButton(2).Text = 'Process';
h_shapeButton(3).Text = 'Unload';

% position

setGap(cb, [10 20])
newRow(cb);
h_posLabel = addMessage(cb);
h_posLabel.Text = 'Position (mm)';
h_posLabel.FontWeight = 'Bold';
h_posLabel.FontSize = 20;
setGap(cb, [10 10]);

newRow(cb);
h_posSlider = [addSlider(cb, [0 10]) addEdit(cb, [0 3])];
h_posSlider(3) = [];
h_posSliderRadio = addRadio(cb, 1, 3, 'h', 'off');
h_posSliderRadio(1).Text = 'x';
h_posSliderRadio(2).Text = 'y';
h_posSliderRadio(3).Text = 'z';

setGap(cb, [10 0]);
newRow(cb);
h_posEdit = [addEdit(cb, 3) addEdit(cb, 3) addEdit(cb, 3)];
h_posEdit(1).Text = 'x';
h_posEdit(3).Text = 'y';
h_posEdit(5).Text = 'z';
setGap(cb, [10 10]);

% orientation

setGap(cb, [10 20]);
newRow(cb);
h_orLabel = addMessage(cb);
h_orLabel.Text = 'Orientation (deg)';
h_orLabel.FontWeight = 'Bold';
h_orLabel.FontSize = 20;
setGap(cb, [10 10]);

newRow(cb);
h_orSlider = [addSlider(cb, [0 10]) addEdit(cb, [0 3])];
h_orSlider(3) = [];
h_orSliderRadio = addRadio(cb, 1, 3, 'h', 'off');
h_orSliderRadio(1).Text = 'x';
h_orSliderRadio(2).Text = 'y';
h_orSliderRadio(3).Text = 'z';

setGap(cb, [10 0]);
newRow(cb);
h_orEdit = [addEdit(cb, 3) addEdit(cb, 3) addEdit(cb, 3)];
h_orEdit(1).Text = 'x';
h_orEdit(3).Text = 'y';
h_orEdit(5).Text = 'z';

setGap(cb, [10 10]);
newRow(cb);
h_orButton = addButton(cb, 5);
h_orButton.Text = 'Reset';

% finalize and position cb

fit(cb)
locate(cb, 'West', mainFigure);
show(cb);

%% defaults

obj = get(mainFigure, 'UserData');
obj = obj.detector;

set(h_shapeRadio(1), 'Tag', 'shape1')
set(h_shapeRadio(2), 'Tag', 'shape2')
set(h_shapeEdit(2), 'Tag', 'size1')
set(h_shapeEdit(4), 'Tag', 'size2');
set(h_shapeEdit(1), 'Tag', 'label1');
set(h_shapeEdit(3), 'Tag', 'label2');

set(h_shapeEdit(2), 'Value', num2str(obj.size(1)));
switch obj.shape
    case 'rectangle'
        set(h_shapeEdit(4), 'Value', num2str(obj.size(2)));
    case 'circle'
        set(h_shapeRadio(2), 'Value', 1);
        set(h_shapeEdit(1), 'Text', 'Diameter');
        set(h_shapeEdit(3), 'Text', '');
        set(h_shapeEdit(4), 'enable', 'off');
        set(h_shapeEdit(4), 'Value', '');
end

set(h_shapeSlider(2), 'Value', obj.faceAlpha);
set(h_shapeSlider(3), 'Value', num2str(obj.faceAlpha));
set(h_shapeSlider(2), 'Limits', [0 1]);
set(h_shapeSlider(2), 'MajorTicks', 0:.25:1);
set(h_shapeSlider(2), 'Tag', 'alphaSlide')
set(h_shapeSlider(3), 'Tag', 'alphaEdit')

set(h_posSlider(2), 'Value', 0);
set(h_posSlider(3), 'Value', '0');
set(h_posSlider(3), 'Enable', 'off');
set(h_posSlider(2), 'Limits', [-1 1]);
set(h_posSlider(2), 'MajorTicks', -1:.5:1);
set(h_posEdit(2), 'Value', num2str(obj.location(1)));
set(h_posEdit(4), 'Value', num2str(obj.location(2)));
set(h_posEdit(6), 'Value', num2str(obj.location(3)));

set(h_orSlider(2), 'Value', 0);
set(h_orSlider(3), 'Value', '0');
set(h_orSlider(3), 'Enable', 'off');
set(h_orSlider(2), 'Limits', [-1 1]);
set(h_orSlider(2), 'MajorTicks', -1:.5:1);
set(h_orEdit(2), 'Value', num2str(obj.orientation(1)));
set(h_orEdit(4), 'Value', num2str(obj.orientation(2)));
set(h_orEdit(6), 'Value', num2str(obj.orientation(3)));

%% callback assignments

% close

category = 'detector';
set(cb.Figure, 'CloseRequestFcn', {@closeDlg, mainFigure, category, ...
    {'location', 'orientation'}});

% shape

set(get(h_shapeRadio(1), 'parent'), 'SelectionChangedFcn', {@detectorShapeRadio, mainFigure, ...
    h_shapeRadio, h_shapeEdit});
set(findobj(h_shapeEdit, 'Type', 'uieditfield'), 'ValueChangedFcn', {@detectorShapeEdit, mainFigure, ...
    h_shapeEdit, h_shapeRadio});
fcn = @(src, event)detectorShapeSlider(src, event, mainFigure, h_shapeSlider(3));
set(h_shapeSlider(2), 'ValueChangingFcn', fcn);
set(h_shapeSlider(2), 'ValueChangedFcn', fcn);
set(h_shapeSlider(3), 'ValueChangedFcn', {@detectorShapeSliderEdit, ...
    mainFigure, h_shapeSlider});
set(h_shapeButton(1), 'ButtonPushedFcn', {@detectorShapeButtonLoad, mainFigure});
set(h_shapeButton(2), 'ButtonPushedFcn', {@processDlg, mainFigure});
set(h_shapeButton(3), 'ButtonPushedFcn', {@detectorShapeButtonUnload, ...
    mainFigure, h_shapeSlider});

% location

subcategory = 'location';
set(h_posSlider(2), 'ValueChangingFcn', ...
    @(src,event)xyzSliderListener(src, event, mainFigure, h_posSlider(3), ...
    h_posSliderRadio, h_posEdit, category, subcategory));
set(h_posSlider(2), 'ValueChangedFcn', {@xyzSliderRelease, mainFigure, h_posSlider(3), ...
    h_posSliderRadio, h_posEdit, category, subcategory});
set(get(h_posSliderRadio(1), 'parent'), 'SelectionChangedFcn', @(src, event)resetReference(mainFigure, ...
    h_posSlider, category, subcategory));
set(findobj(h_posEdit, 'Type', 'uieditfield'), 'ValueChangedFcn', {@changeEdit, mainFigure, h_posEdit, ...
    h_posSlider, category, subcategory});

% orientation

subcategory = 'orientation';
set(h_orSlider(2), 'ValueChangingFcn', ...
    @(src,event)xyzSliderListener(src, event, mainFigure, h_orSlider(3), ...
    h_orSliderRadio, h_orEdit, category, subcategory));
set(h_orSlider(2), 'ValueChangedFcn', {@xyzSliderRelease, mainFigure, h_orSlider(3), ...
    h_orSliderRadio, h_orEdit, category, subcategory});
set(get(h_orSliderRadio(1), 'parent'), 'SelectionChangedFcn', @(src, event)resetReference(mainFigure, ...
    h_orSlider, category, subcategory));
set(findobj(h_orEdit, 'Type', 'uieditfield'), 'ValueChangedFcn', {@changeEdit, mainFigure, h_orEdit, ...
    h_orSlider, category, subcategory});
set(h_orButton, 'ButtonPushedFcn', {@orientationResetButton, mainFigure, ...
    h_orEdit, h_orSlider, category});

end

%% callbacks specific to this dlg (other than process button)

function detectorShapeRadio(src, event, mainFigure, h_radio, h_edit)

obj = get(mainFigure, 'UserData');
if ~isnumeric(obj.detector.image)
    set(h_radio(1), 'Value', 1);
    warndlg('Can''t have a circular image');
    return
end

if h_radio(1).Value
    set(h_edit(1), 'Text', 'Height');
    set(h_edit(3), 'Text', 'Width');
    set(h_edit(4), 'enable', 'on');
    set(h_edit(4), 'Value', num2str(obj.detector.size(2)));
    obj = changeObject(obj, 'detector', 'shape', 'rectangle');
else
    set(h_edit(1), 'Text', 'Diameter');
    set(h_edit(3), 'Text', '');
    set(h_edit(4), 'enable', 'off');
    set(h_edit(4), 'Value', '');
    obj = changeObject(obj, 'detector', 'shape', 'circle');
end

set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure);

end

function detectorShapeEdit(src, event, mainFigure, h_edit, h_radio)

obj = get(mainFigure, 'UserData');
newSize = editExtract(h_edit);
ind = [h_radio.Value];
if ind(1)
    updateFromEdit(mainFigure, newSize, 'detector', 'size', h_edit, true);
else
    oldSize = obj.detector.size;
    if isnan(newSize(1))
        newSize = oldSize;
    end
    obj = changeObject(obj, 'detector', 'size', [newSize(1), oldSize(2)]);
    set(h_edit(2), 'Value', num2str(obj.detector.size(1)));
    set(mainFigure, 'UserData', obj);
    updatePlotPredictionAnalysis(mainFigure);
end

end

function detectorShapeSlider(src, event, mainFigure, h_edit)

sliderVal = event.Value;
set(h_edit, 'Value', num2str(sliderVal));

obj = get(mainFigure, 'UserData');
obj = changeObject(obj, 'detector', 'faceAlpha', sliderVal);
set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure);

end

function detectorShapeSliderEdit(src, event, mainFigure, h_slider)

sliderVal = editExtract(h_slider(3));
updateFromEdit(mainFigure, sliderVal, 'detector', 'faceAlpha', ...
    h_slider(3), true);

obj = get(mainFigure, 'UserData');
set(h_slider(2), 'Value', obj.detector.faceAlpha);
% updatePlotPredictionAnalysis(mainFigure);

end

function detectorShapeButtonLoad(src, event, mainFigure)
importDetectorImage(mainFigure); % silly but necessary to keep as helper function and not make it a callback
end

function detectorShapeButtonUnload(src, event, mainFigure, h_slider)

obj = get(mainFigure, 'UserData');
obj = changeObject(obj, 'detector', 'image', -1);
obj = changeObject(obj, 'detector', 'faceAlpha', 0.75);
set(h_slider(2), 'Value', obj.detector.faceAlpha);
set(h_slider(3), 'Value', sprintf('%.2f',obj.detector.faceAlpha));
if isappdata(mainFigure, 'processDlg')
    db = getappdata(mainFigure, 'processDlg');
    if isvalid(db)
        delete(db.Figure)
    end
end
set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure);

end