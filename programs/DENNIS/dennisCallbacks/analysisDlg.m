function analysisDlg(src, event)

%% build cb

[cb, mainFigure, ex] = createCB(src, mfilename);
if ex
    return
end
name = 'Powder Diffraction Image Analysis';

% azimuthal integration

h_label = addMessage(cb);
h_label.Text = 'Azimuthal Integration';
h_label.FontWeight = 'Bold';
h_label.FontSize = 20;

setGap(cb, [10 0]);
newRow(cb);
h_edit = addEdit(cb, 5);
h_edit(1).Text = 'Res (deg)';
h_edit(2).Tag = 'edit';

newRow(cb);
h_check = addCheckbox(cb, 15);
h_check.Text = ' Average bin value?';
h_check.Tag = 'check';

newRow(cb);
h_checkSplit = addCheckbox(cb, 15);
h_checkSplit.Text = ' Split pixels (bbox)?';
h_checkSplit.Tag = 'checkSplit';

newRow(cb);
h_checkLP = addCheckbox(cb, 15);
h_checkLP.Text = ' Switch LP correction to results?';
h_checkLP.Tag = 'checkLP';
setGap(cb, [10 10]);

% cake plot

newRow(cb);
h_cakeLabel = addMessage(cb);
h_cakeLabel.Text = 'Cake Plot';
h_cakeLabel.FontWeight = 'Bold';
h_cakeLabel.FontSize = 20;
setGap(cb, [10 0]);

newRow(cb);
h_cakeEdit = [addEdit(cb, 7) addEdit(cb, 7)];
h_cakeEdit(1).Text = '2θ Res (deg)';
h_cakeEdit(3).Text = 'χ Res (deg)';
h_cakeEdit(2).Tag = 'thetaEdit';
h_cakeEdit(4).Tag = 'chiEdit';

newRow(cb);
h_cakeEditRot = addEdit(cb,8);
h_cakeEditRot(1).Text = 'χ Ref Rot (deg)';
h_cakeEditRot(2).Tag = 'chiRotEdit';

newRow(cb);
h_cakeCheck = addCheckbox(cb, 15);
h_cakeCheck.Text = ' Average bin value?';
h_cakeCheck.Tag = 'cakeCheckAverage';

newRow(cb);
h_cakeCheck = addCheckbox(cb, 15);
h_cakeCheck.Text = ' Split pixels (bbox)?';
h_cakeCheck.Tag = 'cakeCheck';
setGap(cb, [10 10]);

newRow(cb);
h_cakeButton = addButton(cb, 5);
h_cakeButton.Text = 'Plot';
h_cakeButton.Tag = 'button';

%% build combined

[new, fig, ax] = createCombined(mainFigure, cb, name);

set(fig, 'Units', 'normalized');
set(fig, 'Position', [0.1 0.1 0.6 0.5]);
movegui(fig, 'center');
set(fig, 'Units', 'pixels');

h_edit = findobj(new, 'tag', 'edit');
h_check = findobj(new, 'tag', 'check');
h_checkSplit = findobj(new, 'tag', 'checkSplit');
h_checkLP = findobj(new, 'tag', 'checkLP');
h_thetaEdit = findobj(new, 'tag', 'thetaEdit');
h_chiEdit = findobj(new, 'tag', 'chiEdit');
h_chiRotEdit = findobj(new, 'tag', 'chiRotEdit');
h_button = findobj(new, 'tag', 'button');
h_cakeCheck = findobj(new, 'tag', 'cakeCheck');
h_cakeCheckAverage = findobj(new, 'tag', 'cakeCheckAverage');

%% defaults
% Dolan recommends doing after combining

obj = get(mainFigure, 'UserData');
set(h_edit, 'Value', num2str(obj.results.twoThetaResolution));
set(h_check, 'Value', obj.results.average);
set(h_checkSplit, 'Value', obj.results.splitPixels);
set(h_checkLP, 'Value', obj.results.applyLPCorrection);

set(h_thetaEdit, 'Value', num2str(obj.results.cake.twoThetaResolution));
set(h_chiEdit, 'Value', num2str(obj.results.cake.chiResolution));
set(h_chiRotEdit, 'Value', num2str(obj.results.cake.chiRotation));
set(h_cakeCheck, 'Value', obj.results.cake.splitPixels);
set(h_cakeCheckAverage, 'Value', obj.results.cake.average);

xlabel(ax, '2θ (deg)')
ylabel(ax, 'Normalized Intensity (au)')
hold(ax, 'on')

if ~isnumeric(obj.detector.image)
    updatePlotPredictionAnalysis(mainFigure, 'results');
else
    importDetectorImage(mainFigure);
    obj = get(mainFigure, 'UserData');
    if isnumeric(obj.detector.image)
        close(fig)
        return
    end
end

figure(fig);

%% callback assignments
% Dolan recommends doing after combining

set(h_edit, 'ValueChangedFcn', {@analysisEdit, mainFigure, h_edit});
set(h_check, 'ValueChangedFcn', {@analysisCheck, mainFigure, h_check});
set(h_checkSplit, 'ValueChangedFcn', {@analysisCheckSplit, mainFigure, h_checkSplit});
set(h_checkLP, 'ValueChangedFcn', {@analysisCheckLP, mainFigure, h_checkLP});

set(h_thetaEdit, 'ValueChangedFcn', {@cakeThetaEdit, mainFigure, h_thetaEdit});
set(h_chiEdit, 'ValueChangedFcn', {@cakeChiEdit, mainFigure, h_chiEdit});
set(h_chiRotEdit, 'ValueChangedFcn', {@cakeRotEdit, mainFigure, h_chiRotEdit});
set(h_cakeCheck, 'ValueChangedFcn', {@cakeCheck, mainFigure, h_cakeCheck});
set(h_cakeCheckAverage, 'ValueChangedFcn', {@cakeCheckAverage, mainFigure, h_cakeCheckAverage});
set(h_button, 'ButtonPushedFcn', {@cakeButton, mainFigure});

end

function analysisEdit(src, event, mainFigure, h_edit)

newVal = editExtract(h_edit);
obj = get(mainFigure, 'UserData');

if isnan(newVal)
    newVal = obj.results.twoThetaResolution;
end

updateFromEdit(mainFigure, newVal, 'results', 'twoThetaResolution', ...
    h_edit, false);

end

function analysisCheck(src, event, mainFigure, h_check)

newVal = logical(get(h_check, 'Value'));
obj = get(mainFigure, 'UserData');
obj = changeObject(obj, 'results', 'average', newVal);
set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure, 'results');

end

function analysisCheckSplit(src, event, mainFigure, h_check)

newVal = logical(get(h_check, 'Value'));
obj = get(mainFigure, 'UserData');
obj = changeObject(obj, 'results', 'splitpixels', newVal);
set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure, 'results');

end

function analysisCheckLP(src, event, mainFigure, h_check)

newVal = logical(get(h_check, 'Value'));
obj = get(mainFigure, 'UserData');
obj = changeObject(obj, 'results', 'applylpcorrection', newVal);
set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure);

end

function cakeThetaEdit(src, event, mainFigure, h_edit)

newVal = editExtract(h_edit);
obj = get(mainFigure, 'UserData');

if isnan(newVal)
    newVal = obj.results.cake.twoThetaResolution;
end

obj = changeObject(obj, 'results', 'cake', 'twoThetaResolution', newVal);
set(mainFigure,'UserData',obj);
h_edit.Value = num2str(obj.results.cake.twoThetaResolution);

end

function cakeChiEdit(src, event, mainFigure, h_edit)

newVal = editExtract(h_edit);
obj = get(mainFigure, 'UserData');

if isnan(newVal)
    newVal = obj.results.cake.chiResolution;
end

obj = changeObject(obj, 'results', 'cake', 'chiResolution', newVal);
set(mainFigure,'UserData',obj);
h_edit.Value = num2str(obj.results.cake.chiResolution);

end

function cakeRotEdit(src, event, mainFigure, h_edit)

newVal = editExtract(h_edit);
obj = get(mainFigure, 'UserData');

if isnan(newVal)
    newVal = obj.results.cake.chiRotation;
end

obj = changeObject(obj, 'results', 'cake', 'chiRotation', newVal);
set(mainFigure,'UserData',obj);
h_edit.Value = num2str(obj.results.cake.chiRotation);

end

function cakeCheck(src, event, mainFigure, h_check)

newVal = logical(get(h_check, 'Value'));
obj = get(mainFigure, 'UserData');
obj = changeObject(obj, 'results', 'cake', 'splitpixels', newVal);
set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure, 'results');

end

function cakeCheckAverage(src, event, mainFigure, h_check)

newVal = logical(get(h_check, 'Value'));
obj = get(mainFigure, 'UserData');
obj = changeObject(obj, 'results', 'cake', 'average', newVal);
set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure, 'results');

end

function cakeButton(src, event, mainFigure)
obj = get(mainFigure, 'UserData');
obj = generateCake(obj);
set(mainFigure, 'UserData', obj);
end
