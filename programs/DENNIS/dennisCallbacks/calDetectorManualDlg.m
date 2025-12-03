function calDetectorManualDlg(src, event, mainFigure)

%% build cb

[cb, ~, ex] = createCB(src, mfilename);
if ex
    return
end
name = 'Detector Calibration';
close(ancestor(src,'figure'));

% roi selection

h = addMessage(cb);
h.Text = 'ROI Selection';
h.FontWeight = 'Bold';
h.FontSize = 20;

setGap(cb, [10 0]);
newRow(cb);
h = addButton(cb, 6);
h.Text = 'Background';
h.Tag = h.Text;
h = addEdit(cb, 4);
h(1).Text = 'Thresh';
h(2).Tag = h(1).Text;
setGap(cb, [10 10]);

newRow(cb);
h = addButton(cb, 5);
h.Text = 'Split';
h.Tag = h.Text;
h = addButton(cb, 5);
h.Text = 'Mask';
h.Tag = h.Text;

% poi selection

setGap(cb, [10 20]);
newRow(cb);
h = addMessage(cb);
h.Text = 'POI Selection';
h.FontWeight = 'Bold';
h.FontSize = 20;

setGap(cb, [10 0]);
newRow(cb);
h = addEdit(cb, 7);
h(1).Text = 'Min Reg Size';
h(2).Tag = h(1).Text;
h = addEdit(cb, 7);
h(1).Text = 'Min Pt Dist';
h(2).Tag = h(1).Text;

newRow(cb);
h = addEdit(cb, 7);
h(1).Text = 'Max Pt Num';
h(2).Tag = h(1).Text;
h = addEdit(cb, 7);
h(1).Text = 'Int Cutoff';
h(2).Tag = h(1).Text;
setGap(cb, [10 10]);

newRow(cb);
h = addButton(cb, 5);
h.Text = 'Find';
h.Tag = h.Text;

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
h = [addEdit(cb, 3) addEdit(cb, 3) addEdit(cb, 3)];
h(1).Text = '± x';
h(3).Text = '± y';
h(5).Text = '± z';
h(2).Tag = 'calEdit';
h(4).Tag = 'calEdit';
h(6).Tag = 'calEdit';

newRow(cb);
h = [addEdit(cb, 3) addEdit(cb, 3) addEdit(cb, 3)];
h(1).Text = '± Rx';
h(3).Text = '± Ry';
h(5).Text = '± Rz';
h(2).Tag = 'calEdit';
h(4).Tag = 'calEdit';
h(6).Tag = 'calEdit';
setGap(cb, [10 10]);

newRow(cb);
h = addButton(cb, 5);
h.Text = 'Solve';
h.Tag = h.Text;

%% build combined

[new, fig, ax] = createCombined(mainFigure, cb, name);

% recover original DENNIS handle names
% Dolan tags and then names after combining in his examples

h_roiEdit = findobj(new, 'Tag', 'Thresh');
h_roiButtonBack = findobj(new, 'Tag', 'Background');
h_roiButtonSplit = findobj(new, 'Tag', 'Split');
h_roiButtonMask = findobj(new, 'Tag', 'Mask');

h_poiEditSize = findobj(new, 'Tag', 'Min Reg Size');
h_poiEditDist = findobj(new, 'Tag', 'Min Pt Dist');
h_poiEditNum = findobj(new, 'Tag', 'Max Pt Num');
h_poiEditCutoff = findobj(new, 'Tag', 'Int Cutoff');
h_poiButton = findobj(new, 'Tag', 'Find');

h_calEditSize = findobj(new, 'Tag', 'Pop Size:');
h_calEditBounds = findobj(new, 'Tag', 'calEdit');
h_calButton = findobj(new, 'Tag', 'Solve');

%% set defaults

obj = get(mainFigure, 'UserData');
obj = changeObject(obj, 'calibration', 'type', 'detectorManual');

set(ax, 'FontSize', 16)
set(ax.Title, 'Visible', 'off');
hold(ax, 'on')
view(obj.detector.image, 'show', ax, true);
axis(ax, 'equal');
delete(findobj(fig, 'type', 'colorbar'));

set(h_calEditSize(1), 'Value', num2str(obj.calibration.opts.gaOpts.PopulationSize, '%.0g'));
set(h_calEditBounds(1), 'Value', num2str(obj.calibration.searchBounds(1)));
set(h_calEditBounds(2), 'Value', num2str(obj.calibration.searchBounds(2)));
set(h_calEditBounds(3), 'Value', num2str(obj.calibration.searchBounds(3)));
set(h_calEditBounds(4), 'Value', num2str(obj.calibration.searchBounds(4)));
set(h_calEditBounds(5), 'Value', num2str(obj.calibration.searchBounds(5)));
set(h_calEditBounds(6), 'Value', num2str(obj.calibration.searchBounds(6)));

%% set callbacks

set(h_roiEdit, 'ValueChangedFcn', {@changeOptEdit, mainFigure, h_roiEdit, ...
    'threshold'});
set(h_roiButtonBack, 'ButtonPushedFcn', {@pressBackButton, mainFigure, ax})
set(h_roiButtonSplit, 'ButtonPushedFcn', {@pressSplitButton, mainFigure, ax})
set(h_roiButtonMask, 'ButtonPushedFcn', {@pressMaskButton, mainFigure, ax})

set(h_poiEditSize, 'ValueChangedFcn', {@changeOptEdit, mainFigure, h_poiEditSize, ...
    'minRegSize'});
set(h_poiEditDist, 'ValueChangedFcn', {@changeOptEdit, mainFigure, h_poiEditDist, ...
    'minPointDist'});
set(h_poiEditNum, 'ValueChangedFcn', {@changeOptEdit, mainFigure, h_poiEditNum, ...
    'maxPointNum'});
set(h_poiEditCutoff, 'ValueChangedFcn', {@changeOptEdit, mainFigure, h_poiEditCutoff, ...
    'intCutoff'});
set(h_poiButton, 'ButtonPushedFcn', {@pressFindButton, mainFigure, ax})

set(h_calEditSize, 'ValueChangedFcn', {@changeCalEditSize, mainFigure, ...
    h_calEditSize});
set(h_calEditBounds, 'ValueChangedFcn', {@changeEdit, mainFigure, h_calEditBounds, ...
    nan, 'calibration', 'searchBounds'});
set(h_calButton, 'ButtonPushedFcn', {@pressCalButton, mainFigure})

% show figure

figure(fig);

%% initial solve

obj = calThresh(obj);
set(h_roiEdit(1), 'Value', num2str(obj.calibration.opts.threshold));
set(h_poiEditSize(1), 'Value', num2str(obj.calibration.opts.minRegSize));
set(h_poiEditDist(1), 'Value', num2str(obj.calibration.opts.minPointDist));
set(h_poiEditNum(1), 'Value', num2str(obj.calibration.opts.maxPointNum));
set(h_poiEditCutoff(1), 'Value', num2str(obj.calibration.opts.intCutoff));
set(mainFigure, 'UserData', obj);

end

%% callback functions

function changeOptEdit(src, event, mainFigure, h, opt)
obj = get(mainFigure, 'UserData');
obj = changeObject(obj, 'calibration', 'opts', opt, editExtract(h));
set(h(1), 'Value', num2str(obj.calibration.opts.(opt)));
set(mainFigure, 'UserData', obj);
end

function pressBackButton(source, event, mainFigure, ax)
obj = get(mainFigure, 'UserData');
obj = calProcessImage(obj, 'background');
view(obj.calibration.processedImage, 'show', ax);
delete(findobj(ancestor(ax,'figure'), 'type', 'colorbar'));
axis(ax, 'equal');
set(mainFigure, 'UserData', obj);
end

function pressSplitButton(source, event, mainFigure, ax)
obj = get(mainFigure, 'UserData');
obj = calProcessImage(obj, 'mask', ax, {'connected', 'y', 2});
view(obj.calibration.processedImage, 'show', ax);
delete(findobj(ancestor(ax,'figure'), 'type', 'colorbar'));
axis(ax, 'equal');
set(mainFigure, 'UserData', obj);
end

function pressMaskButton(source, event, mainFigure, ax)
obj = get(mainFigure, 'UserData');
obj = calProcessImage(obj, 'mask', ax);
view(obj.calibration.processedImage, 'show', ax);
delete(findobj(ancestor(ax,'figure'), 'type', 'colorbar'));
axis(ax, 'equal');
set(mainFigure, 'UserData', obj);
end

function pressFindButton(source, event, mainFigure, ax)
obj = get(mainFigure, 'UserData');
obj = calCC(obj);
obj = calPOI(obj);
delete(findobj(ax,'Type','Line'))
for ii = 1:size(obj.calibration.poi,3)
    plot(ax, obj.calibration.poi(:,1,ii), obj.calibration.poi(:,2,ii), ...
        'r*', 'markersize', 5);
end
set(mainFigure, 'UserData', obj);
end

function changeCalEditSize(src, event, mainFigure, h)
obj = get(mainFigure, 'UserData');
obj = changeObject(obj, 'calibration', 'opts', 'gaPopulation', editExtract(h));
set(h(1), 'Value', num2str(obj.calibration.opts.gaOpts.PopulationSize, '%.0g'));
set(mainFigure, 'UserData', obj);
end

function pressCalButton(src, event, mainFigure)
close(ancestor(src,'figure'));
obj = get(mainFigure, 'UserData');
[obj, score] = calSolve(obj);
fprintf('Final GA score of %d\n', score);
set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure);
end



