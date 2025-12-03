function calCrystalDlg(src, event, mainFigure)

%% build cb

[cb, ~, ex] = createCB(src, mfilename);
if ex
    return
end
name = 'Detector Calibration';
close(ancestor(src,'figure'))

% poi selection

h = addMessage(cb);
h.Text = 'POI Selection';
h.FontWeight = 'Bold';
h.FontSize = 20;

newRow(cb);
h = addMessage(cb, 7);
h.Text = 'ROI Selection:';
setGap(cb, [0 10]);
h = addRadio(cb, [3 4], 2, 'h', 'off');
h(1).Text = 'Auto';
h(2).Text = 'Manual';
set(h, 'Tag', 'roiRadio');

newRow(cb);
h = addMessage(cb, 5);
h.Text = 'ROI num:';
setGap(cb, [0 10])
h = addEdit(cb, [0 4]);
h(2).Tag = 'ROI num:';
setGap(cb, [10 10]);

newRow(cb);
h = addMessage(cb, 7);
h.Text = 'POI Selection:';
setGap(cb, [0 10]);
h = addRadio(cb, [3 3 3], 3, 'h', 'off');
h(1).Text = 'Mean';
h(2).Text = 'Max';
h(3).Text = 'Exact';
set(h, 'Tag', 'poiRadio');

% calibration

setGap(cb, [10 20]);
newRow(cb);
h = addMessage(cb);
h.Text = 'Calibration';
h.FontWeight = 'Bold';
h.FontSize = 20;
setGap(cb, [10 10]);

newRow(cb);
h = addMessage(cb, 5);
h.Text = 'Pop Size:';
setGap(cb, [0 10])
h = addEdit(cb, [0 4]);
h(2).Tag = 'Pop Size:';
setGap(cb, [10 10]);

setGap(cb, [10 0]);
newRow(cb);
h = [addEdit(cb, 3) addEdit(cb, 3) addEdit(cb, 3) addEdit(cb, 3)];
h(1).Text = '± x';
h(3).Text = '± y';
h(5).Text = '± z';
h(7).Text = '± V';
set(h, 'Tag', 'calEdit');
setGap(cb, [10 10]);

newRow(cb);
h = addRadio(cb, 2, 2, 'h', 'off');
h(1).Text = 'xyz';
h(2).Text = 'abc';
set(h, 'Tag', 'calRadio');

newRow(cb);
h = addButton(cb, 5);
h.Text = 'Solve';
h.Tag = h.Text;

%% build combined

[new, fig, ax] = createCombined(mainFigure, cb, name);

% recover original DENNIS handle names
% Dolan tags and then names after combining in his examples

h_roiRadio = [findobj(new, 'text', 'Auto'), findobj(new, 'text', 'Manual')]; % necessary to specify order here
h_roiEdit = findobj(new, 'tag', 'ROI num:');
h_poiRadio = findobj(new, 'tag', 'poiRadio');

h_calSizeEdit = findobj(new, 'tag', 'Pop Size:');
h_calBoundsEdit = findobj(new, 'tag', 'calEdit');
h_calRadio = findobj(new, 'tag', 'calRadio');
h_calButton = findobj(new, 'tag', 'Solve');

%% set defaults

obj = get(mainFigure, 'UserData');
obj = changeObject(obj, 'calibration', 'type', 'crystal');
obj = changeObject(obj, 'crystal', 'orientationSystem', 'xyz'); % abc may not search entire space

set(ax, 'FontSize', 16)
set(ax.Title, 'Visible', 'off');
hold(ax, 'on')
view(obj.detector.image, 'show', ax);
axis(ax, 'equal');
delete(findobj(fig, 'type', 'colorbar'));

set(h_roiEdit(1), 'Value', num2str(obj.calibration.opts.roiNum, '%d'));

set(h_calSizeEdit(1), 'Value', num2str(obj.calibration.opts.gaOpts.PopulationSize, '%.0g'));
set(h_calBoundsEdit(2), 'Value', num2str(obj.calibration.searchBounds(1)));
set(h_calBoundsEdit(4), 'Value', num2str(obj.calibration.searchBounds(2)));
set(h_calBoundsEdit(6), 'Value', num2str(obj.calibration.searchBounds(3)));
set(h_calBoundsEdit(8), 'Value', num2str(obj.calibration.searchBounds(4)));

if strcmp(obj.crystal.orientationSystem, 'abc') % just here in case I ever decide not to force xyz above
    set(h_calRadio(2), 'Value', 1);
end

%% set callbacks

set(get(h_roiRadio(1),'parent'), 'SelectionChangedFcn', {@changeROIRadio, mainFigure, h_roiRadio, ...
    h_roiEdit, ax})
set(h_roiEdit, 'ValueChangedFcn', {@changeROIEdit, mainFigure, h_roiEdit, ...
    ax});
set(get(h_poiRadio(1),'parent'), 'SelectionChangedFcn', {@changePOIRadio, mainFigure, h_poiRadio, ...
    ax})

set(h_calSizeEdit, 'ValueChangedFcn', {@changeCalSizeEdit, mainFigure, ...
    h_calSizeEdit});
set(findobj(h_calBoundsEdit, 'type', 'uieditfield'), 'ValueChangedFcn', {@changeEdit, mainFigure, h_calBoundsEdit, ...
    nan, 'calibration', 'searchBounds'});
set(get(h_calRadio(1), 'parent'), 'SelectionChangedFcn', {@changeCalRadio, mainFigure, h_calRadio, ...
    h_calBoundsEdit})
set(h_calButton, 'ButtonPushedFcn', {@pressCalButton, mainFigure})

%% initial solve

obj = calROI(obj);
obj = calCC(obj);
obj = calPOI(obj);
plot(ax, obj.calibration.poi(:,1), obj.calibration.poi(:,2), ...
    '*', 'color', 'r', 'markersize', 5);
set(mainFigure, 'UserData', obj);

end

%% callback functions

function changeROIRadio(src, event, mainFigure, hRadio, hEdit, ax)
obj = get(mainFigure, 'UserData');
if get(hRadio(1),'Value')
    set(hEdit(1), 'Enable', 'on');
else
    set(hEdit(1), 'Enable', 'off');
end
str = get(get(src, 'SelectedObject'), 'Text');
obj = changeObject(obj, 'calibration', 'opts', 'roiSelect', str);
delete(findobj(ax,'Type','Line'))
obj = calROI(obj, ax);
if isempty(obj.calibration.roi) && get(hRadio(2), 'Value') % user doesn't pick anyting
    set(hRadio(1), 'Value', 1)
    set(hEdit(2), 'Enable', 'on');
    set(hEdit(2), 'Value', '3');
    obj = changeObject(obj, 'calibration', 'opts', 'roiNum', 3);
    obj = changeObject(obj, 'calibration', 'opts', 'roiSelect', 'auto');
        obj = calROI(obj);
end
obj = calCC(obj);
obj = calPOI(obj);
plot(ax, obj.calibration.poi(:,1), obj.calibration.poi(:,2), 'r*', ...
    'markersize', 5);
set(hEdit(1), 'Value', num2str(obj.calibration.opts.roiNum, '%d'));
set(mainFigure, 'UserData', obj);
end

function changeROIEdit(src, event, mainFigure, h, ax)
obj = get(mainFigure, 'UserData');
obj = changeObject(obj, 'calibration', 'opts', 'roiNum', editExtract(h));
set(h(1), 'Value', num2str(obj.calibration.opts.roiNum, '%d'));
obj = calROI(obj, ax);
obj = calCC(obj);
obj = calPOI(obj);
delete(findobj(ax,'Type','Line'))
plot(ax, obj.calibration.poi(:,1), obj.calibration.poi(:,2), 'r*', ...
    'markersize', 5);
set(mainFigure, 'UserData', obj);
end

function changePOIRadio(src, event, mainFigure, hRadio, ax)
obj = get(mainFigure, 'UserData');
str = get(get(src, 'SelectedObject'), 'Text');
obj = changeObject(obj, 'calibration', 'opts', 'poiType', str);
obj = calPOI(obj);
delete(findobj(ax,'Type','Line'))
plot(ax, obj.calibration.poi(:,1), obj.calibration.poi(:,2), 'r*', ...
    'markersize', 5);
set(mainFigure, 'UserData', obj);
end

function changeCalSizeEdit(src, event, mainFigure, h)
obj = get(mainFigure, 'UserData');
obj = changeObject(obj, 'calibration', 'opts', 'gaPopulation', editExtract(h));
set(h(1), 'Value', num2str(obj.calibration.opts.gaOpts.PopulationSize, '%.0g'));
set(mainFigure, 'UserData', obj);
end

function changeCalRadio(src, event, mainFigure, hRadio, hEdit)
obj = get(mainFigure, 'UserData');
str = get(get(src, 'SelectedObject'), 'Text');
set(hEdit(1), 'Text', ['± R', str(1)]);
set(hEdit(3), 'Text', ['± R', str(2)]);
set(hEdit(5), 'Text', ['± R', str(3)]);
obj = changeObject(obj, 'crystal', 'orientationSystem', str);
set(mainFigure, 'UserData', obj);
end

function pressCalButton(src, event, mainFigure)
close(ancestor(src,'figure'));
obj = get(mainFigure, 'UserData');
[obj, score] = calSolve(obj);
set(mainFigure, 'UserData', obj);
fprintf('Final GA score of %d\n', score);
updatePlotPredictionAnalysis(mainFigure);
end



