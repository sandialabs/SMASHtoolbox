function crystalDlg(src, event)

%% build cb

[cb, mainFigure, ex] = createCB(src, mfilename);
if ex
    return
end
setName(cb, 'Crystal');

% position

h_posLabel = addMessage(cb);
h_posLabel.Text = 'Position (mm)';
h_posLabel.FontWeight = 'Bold';
h_posLabel.FontSize = 20;

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

newRow(cb);
h_posCheck = addCheckbox(cb, 20);
h_posCheck.Text = ' Maintain x-ray vector?';

% orientation

newRow(cb);
h_orLabel = addMessage(cb);
h_orLabel.Text = 'Orientation (deg)';
h_orLabel.FontWeight = 'Bold';
h_orLabel.FontSize = 20;

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

setGap(cb, [10 12]);
newRow(cb);
h_orSystemRadio = addRadio(cb, 2, 2, 'h', 'off');
h_orSystemRadio(1).Text = 'xyz';
h_orSystemRadio(2).Text = 'abc';

setGap(cb, [10 11]);
newRow(cb);
h_orButton = addButton(cb, 5);
h_orButton.Text = 'Reset';

% alignment

setGap(cb, [10 20]);
newRow(cb);
h_alignLabel = addMessage(cb);
h_alignLabel.Text = 'Alignment';
h_alignLabel.FontWeight = 'Bold';
h_alignLabel.FontSize = 20;
setGap(cb, [10 0]);

newRow(cb);
h_sourceLabel = addMessage(cb, 4);
h_sourceLabel.Text = 'Source:';
h_alignSourceRadio = addRadio(cb, 1, 3, 'h', 'off');
h_alignSourceRadio(1).Text = 'a';
h_alignSourceRadio(2).Text = 'b';
h_alignSourceRadio(3).Text = 'c';

newRow(cb);
h_alignTargetLabel = addMessage(cb, 4);
h_alignTargetLabel.Text = 'Target:';
h_alignTargetEdit = [addEdit(cb,3) addEdit(cb, 3) addEdit(cb, 3)];
h_alignTargetEdit(1).Text = 'x';
h_alignTargetEdit(3).Text = 'y';
h_alignTargetEdit(5).Text = 'z';
setGap(cb, [10 10]);

newRow(cb);
h = addMessage(cb,4);
h.Text = '';
h_alignTargetRadio = addRadio(cb, [2 4 7], 3, 'h', 'off');
h_alignTargetRadio(1).Text = 'Lab';
h_alignTargetRadio(2).Text = 'Crystal';
h_alignTargetRadio(3).Text = 'Other Crystal';

newRow(cb);
h_alignButton = addButton(cb, 5);
h_alignButton.Text = 'Align';
h_alignCheck = addCheckbox(cb, 16);
h_alignCheck.Text = ' Also rotate source and detector?';

% lattice

setGap(cb, [10 20]);
newRow(cb);
h_latLabel = addMessage(cb);
h_latLabel.Text = 'Lattice';
h_latLabel.FontWeight = 'Bold';
h_latLabel.FontSize = 20;
setGap(cb, [10 10]);

newRow(cb);
h_latSizeSlider = [addSlider(cb, [0 10]) addEdit(cb, [0 3])];
h_latSizeSlider(3) = [];
setGap(cb, [0 10]);
h_latSizeSliderLabel = addMessage(cb, 7);
h_latSizeSliderLabel.Text = 'Volume Ratio';

setGap(cb, [10 0]);
newRow(cb);
h_latSizeEdit = [addEdit(cb, 3) addEdit(cb, 3) addEdit(cb, 3)];
h_latSizeEdit(1).Text = 'a';
h_latSizeEdit(3).Text = 'b';
h_latSizeEdit(5).Text = 'c';
setGap(cb, [0 10]);
h_latSizeLabel = addMessage(cb,6);
h_latSizeLabel.Text = 'Angstrom';

setGap(cb, [10 0]);
newRow(cb);
h_latAngleEdit = [addEdit(cb, 3) addEdit(cb, 3) addEdit(cb, 3)];
h_latAngleEdit(1).Text = 'a';
h_latAngleEdit(3).Text = 'b';
h_latAngleEdit(5).Text = 'c';
setGap(cb, [0 10]);
h_latAngleLabel = addMessage(cb,2);
h_latAngleLabel.Text = 'deg';
setGap(cb, [10 10]);

newRow(cb);
h_latButton = addButton(cb, 5);
h_latButton.Text = 'Load';
h_latCifEdit = addEdit(cb, [0 18]);

% finalize and position cb

fit(cb)
locate(cb, 'West', mainFigure);
show(cb);

%% defaults

objAll = get(mainFigure, 'UserData');
obj = objAll.crystal;

set(h_posSlider(2), 'Value', 0);
set(h_posSlider(3), 'Value', '0');
set(h_posSlider(3), 'Enable', 'off');
set(h_posSlider(2), 'Limits', [-1 1]);
set(h_posSlider(2), 'MajorTicks', [-1 -.5 0 .5 1]);
set(h_posEdit(2), 'Value', num2str(obj.location(1)));
set(h_posEdit(4), 'Value', num2str(obj.location(2)));
set(h_posEdit(6), 'Value', num2str(obj.location(3)));

set(h_orSlider(2), 'Value', 0);
set(h_orSlider(3), 'Value', '0');
set(h_orSlider(3), 'Enable', 'off');
set(h_orSlider(2), 'Limits', [-1 1]);
set(h_orSlider(2), 'MajorTicks', [-1 -.5 0 .5 1]);
set(h_orEdit(2), 'Value', num2str(obj.orientation(1)));
set(h_orEdit(4), 'Value', num2str(obj.orientation(2)));
set(h_orEdit(6), 'Value', num2str(obj.orientation(3)));

str = obj.orientationSystem;
if ~strcmp(str, 'xyz')
    set(h_orSystemRadio(2), 'Value', 1);
end

set(h_orEdit(1), 'Text', str(1));
set(h_orEdit(3), 'Text', str(2));
set(h_orEdit(5), 'Text', str(3));
set(h_orSliderRadio(1), 'Text', str(1));
set(h_orSliderRadio(2), 'Text', str(2));
set(h_orSliderRadio(3), 'Text', str(3));

set(h_alignTargetEdit(2), 'Value', '1');
set(h_alignTargetEdit(4), 'Value', '0');
set(h_alignTargetEdit(6), 'Value', '0');

set(h_latSizeSlider(2), 'Value', obj.volumeRatio);
set(h_latSizeSlider(3), 'Value', num2str(obj.volumeRatio));
set(h_latSizeSlider(2), 'Limits', [1e-3 2]); % avoid zero
set(h_latSizeSlider(2), 'MajorTicks', [1e-3 .5 1 1.5 2]);
set(h_latSizeSlider(2), 'MajorTickLabels', {'0' '0.5' '1' '1.5' '2'})
set(h_latSizeEdit(2), 'Value', num2str(obj.lengths(1)));
set(h_latSizeEdit(4), 'Value', num2str(obj.lengths(2)));
set(h_latSizeEdit(6), 'Value', num2str(obj.lengths(3)));
set(h_latSizeEdit(2), 'Tag', 'a');
set(h_latSizeEdit(4), 'Tag', 'b');
set(h_latSizeEdit(6), 'Tag', 'c');

set(h_latAngleEdit(2), 'Value', num2str(obj.angles(1)));
set(h_latAngleEdit(4), 'Value', num2str(obj.angles(2)));
set(h_latAngleEdit(6), 'Value', num2str(obj.angles(3)));
set(h_latAngleEdit(2), 'Tag', 'alpha');
set(h_latAngleEdit(4), 'Tag', 'beta');
set(h_latAngleEdit(6), 'Tag', 'gamma');

set(h_latCifEdit(2), 'Value', fliplr(strtok(fliplr(obj.CIF), '\/')));
set(h_latCifEdit(2), 'enable', 'off');

%% callback assignments

% close

category = 'crystal';
set(cb.Figure, 'CloseRequestFcn', {@closeDlg, mainFigure, category, ...
    {'location', 'orientation'}});

% position

subcategory = 'location';
set(h_posSlider(2), 'ValueChangingFcn', ...
    @(src,event)xyzSliderListener(src, event, mainFigure, h_posSlider(3), ...
    h_posSliderRadio, h_posEdit, category, subcategory, h_posCheck));
set(h_posSlider(2), 'ValueChangedFcn', @(src,event)xyzSliderRelease(src, event, ...
    mainFigure, h_posSlider(3), h_posSliderRadio, h_posEdit, category, ...
    subcategory, h_posCheck));
set(get(h_posSliderRadio(1), 'parent'), 'SelectionChangedFcn', ...
    @(src, event)resetReference(mainFigure, ...
    h_posSlider, category, subcategory));
set(findobj(h_posEdit, 'Type', 'uieditfield'), 'ValueChangedFcn', ...
    {@changeEdit, mainFigure, h_posEdit, ...
    h_posSlider, category, subcategory, h_posCheck});

% orientation

subcategory = 'orientation';
set(h_orSlider(2), 'ValueChangingFcn', ...
    @(src,event)xyzSliderListener(src, event, mainFigure, h_orSlider(3), ...
    h_orSliderRadio, h_orEdit, category, subcategory));
set(h_orSlider(2), 'ValueChangedFcn', {@xyzSliderRelease, mainFigure, h_orSlider(3), ...
    h_orSliderRadio, h_orEdit, category, subcategory});
set(get(h_orSliderRadio(1), 'parent'), 'SelectionChangedFcn', ...
    @(src, event)resetReference(mainFigure, ...
    h_orSlider, category, subcategory));
set(findobj(h_orEdit, 'Type', 'uieditfield'), 'ValueChangedFcn', ...
    {@changeEdit, mainFigure, h_orEdit, ...
    h_orSlider, category, subcategory});
set(get(h_orSystemRadio(1), 'parent'), 'SelectionChangedFcn', ...
    {@orRadioChange, mainFigure, ...
    h_orEdit, h_orSlider, h_orSliderRadio});
set(h_orButton, 'ButtonPushedFcn', {@orientationResetButton, mainFigure, ...
    h_orEdit, h_orSlider, category});

% align

set(get(h_alignTargetRadio(1), 'parent'), 'SelectionChangedFcn', ...
    {@alignTargetRadioChange, h_alignTargetEdit});
set(h_alignButton, 'ButtonPushedFcn', {@alignButton, mainFigure, ...
    h_alignSourceRadio, h_alignTargetRadio, h_alignTargetEdit, ...
    h_orEdit, h_orSlider, h_orSliderRadio, h_alignCheck});

% lattice

set(h_latSizeSlider(2), 'ValueChangingFcn', ...
    @(src,event)latSizeSliderListener(src, event, mainFigure, h_latSizeSlider));
set(h_latSizeSlider(2), 'ValueChangedFcn', {@latSizeSliderRelease, mainFigure, ...
    h_latSizeSlider});
set(h_latSizeSlider(3), 'ValueChangedFcn', {@latSizeSliderEdit, ...
    mainFigure, h_latSizeSlider});
set(findobj(h_latSizeEdit, 'Type', 'uieditfield'), 'ValueChangedFcn', ...
    {@crystalLatSizeEdit, mainFigure, h_latSizeEdit, ...
    category, 'lengths', h_latSizeSlider});
set(findobj(h_latAngleEdit, 'Type', 'uieditfield'), 'ValueChangedFcn', ...
    {@crystalLatAngleEdit, mainFigure, ...
    h_latAngleEdit, category, 'angles', h_orSlider, h_orEdit, ...
    h_latSizeSlider});
set(h_latButton, 'ButtonPushedFcn', {@crystalLatButton, mainFigure, ...
    h_latCifEdit(2), h_orSlider, h_orEdit, h_latSizeSlider});

end

%% callbacks specific to this cb

function orRadioChange(src, event, mainFigure, h_edit, h_slider, ...
    h_sliderRadio)

obj = get(mainFigure, 'UserData');
str = get(get(src, 'SelectedObject'), 'Text');
obj = changeObject(obj, 'crystal', 'orientationSystem', str);

set(h_edit(1), 'Text', str(1));
set(h_edit(3), 'Text', str(2));
set(h_edit(5), 'Text', str(3));
set(h_sliderRadio(1), 'Text', str(1));
set(h_sliderRadio(2), 'Text', str(2));
set(h_sliderRadio(3), 'Text', str(3));

set(h_edit(2), 'Value', num2str(obj.crystal.orientation(1)));
set(h_edit(4), 'Value', num2str(obj.crystal.orientation(2)));
set(h_edit(6), 'Value', num2str(obj.crystal.orientation(3)));
set(h_slider(2), 'Value', 0);
set(h_slider(3), 'Value', '0');
set(h_sliderRadio(1), 'Value', 1)

set(mainFigure, 'UserData', obj);
 
end

function alignTargetRadioChange(src, event, h_edit)

str = get(get(src, 'SelectedObject'), 'Text');

if strcmpi(str, 'lab')
    set(h_edit(1), 'Text', 'x');
    set(h_edit(3), 'Text', 'y');
    set(h_edit(5), 'Text', 'z');
else
    set(h_edit(1), 'Text', 'a');
    set(h_edit(3), 'Text', 'b');
    set(h_edit(5), 'Text', 'c');
end
 
end

function alignButton(src, event, mainFigure, ...
    h_alignSourceRadio, h_alignTargetRadio, h_alignTargetEdit, ...
    h_orEdit, h_orSlider, h_orSliderRadio, h_alignCheck)

obj = get(mainFigure, 'UserData');

ind = find([h_alignSourceRadio.Value]);
targetVec = editExtract(h_alignTargetEdit);
if any(isnan(targetVec)) || ~any(targetVec) || any(isinf(targetVec))
    errordlg('Invalid Input');
    return
end

if get(h_alignTargetRadio(2),'Value')
    targetVec = sum(targetVec' .* obj.crystal.vectors,1);
elseif get(h_alignTargetRadio(3),'Value')
    [file, path] = uigetfile('*.mat');
    if isnumeric(file)
        return
    end
    targetObj = load(fullfile(path, file),'obj');
    targetObj = targetObj.obj;
    targetVec = sum(targetVec' .* targetObj.crystal.vectors,1);
end

[obj, ang, rotVec] = alignAxis(obj, ind, targetVec);
if get(h_alignCheck, 'Value')
    obj = changeObject(obj, 'source', 'rotate', ang, true, rotVec);
    h = getappdata(mainFigure, 'sourceDlg');
    if ~isempty(h) && isvalid(h) && ishandle(h)
        close(h);
    end
    h = getappdata(mainFigure, 'detectorDlg');
    if ~isempty(h) && isvalid(h) && ishandle(h)
        close(h);
    end
end

set(mainFigure, 'UserData', obj);

set(h_orEdit(2), 'Value', num2str(obj.crystal.orientation(1)));
set(h_orEdit(4), 'Value', num2str(obj.crystal.orientation(2)));
set(h_orEdit(6), 'Value', num2str(obj.crystal.orientation(3)));
set(h_orSlider(2), 'Value', 0);
set(h_orSlider(3), 'Value', '0');
set(h_orSliderRadio(1), 'Value', 1)

updatePlotPredictionAnalysis(mainFigure);

end

function latSizeSliderListener(src, event, mainFigure, h_slider)

sliderVal = sliderExtract(event, h_slider(3), false);
obj = get(mainFigure, 'UserData');
obj = changeObject(obj, 'crystal', 'volumeratio', sliderVal);
set(mainFigure, 'UserData', obj);

updatePlotPredictionAnalysis(mainFigure, 'crystal');

end

function latSizeSliderRelease(src, event, mainFigure, h_slider)

latSizeSliderListener(src, event, mainFigure, h_slider);
updatePlotPredictionAnalysis(mainFigure);

end

function latSizeSliderEdit(src, event, mainFigure, h_slider)

sliderVal = editExtract(h_slider(3));
if isnan(sliderVal) || sliderVal < h_slider(2).Limits(1) || ...
        sliderVal > h_slider(2).Limits(2)
    sliderVal = h_slider(2).Value;
end
obj = get(mainFigure, 'UserData');
obj = changeObject(obj, 'crystal', 'volumeratio', sliderVal);
set(mainFigure, 'UserData', obj);
set(h_slider(2), 'Value', round(obj.crystal.volumeRatio, 9)); % avoid machine rounding errors near limit
set(h_slider(3), 'Value', num2str(obj.crystal.volumeRatio));

updatePlotPredictionAnalysis(mainFigure);

end

function crystalLatSizeEdit(src, event, mainFigure, h_edit, category, ...
    subcategory, h_latSizeSlider)

new = editExtract(h_edit);
updateFromEdit(mainFigure, new, category, subcategory, h_edit, true);

obj = get(mainFigure, 'UserData');
obj = changeObject(obj, 'crystal', 'lengthsreference', obj.crystal.lengths);
set(h_latSizeSlider(2), 'Value', obj.crystal.volumeRatio);
set(h_latSizeSlider(3), 'Value', num2str(obj.crystal.volumeRatio));
set(mainFigure, 'UserData', obj);

end

function crystalLatAngleEdit(src, event, mainFigure, h_edit, category, ...
    subcategory, h_orSlider, h_orEdit, h_latSizeSlider)

new = editExtract(h_edit);
updateFromEdit(mainFigure, new, category, subcategory, h_edit, true);

obj = get(mainFigure, 'UserData');
set(h_orSlider(2), 'Value', 0);
set(h_orSlider(3), 'Value', '0');
set(h_orEdit(2), 'Value', num2str(obj.crystal.orientation(1)));
set(h_orEdit(4), 'Value', num2str(obj.crystal.orientation(2)));
set(h_orEdit(6), 'Value', num2str(obj.crystal.orientation(3)));

set(h_latSizeSlider(2), 'Value', obj.crystal.volumeRatio);
set(h_latSizeSlider(3), 'Value', num2str(obj.crystal.volumeRatio));
set(mainFigure, 'UserData', obj);

end

function crystalLatButton(src, event, mainFigure, h_edit, h_orSlider, ...
    h_orEdit, h_latSizeSlider)

[file, path] = uigetfile('*.cif');
if isnumeric(file)
    return
end
cifPath = fullfile(path, file);

try
    obj = get(mainFigure, 'UserData');
    obj = changeObject(obj, 'crystal', 'CIF', cifPath);
catch
    errordlg('Failed to load CIF')
    return
end

set(mainFigure, 'UserData', obj);
set(h_edit, 'Value', fliplr(strtok(fliplr(obj.crystal.CIF), '\/')));
set(h_orSlider(2), 'Value', 0);
set(h_orSlider(3), 'Value', '0');
set(h_orEdit(2), 'Value', num2str(obj.crystal.orientation(1)));
set(h_orEdit(4), 'Value', num2str(obj.crystal.orientation(2)));
set(h_orEdit(6), 'Value', num2str(obj.crystal.orientation(3)));
set(h_latSizeSlider(2), 'Value', obj.crystal.volumeRatio);
set(h_latSizeSlider(3), 'Value', num2str(obj.crystal.volumeRatio));

updatePlotPredictionAnalysis(mainFigure);

end