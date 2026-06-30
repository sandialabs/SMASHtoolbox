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
h_check.Text = ' Average along arc?';
h_check.Tag = 'check';
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
h_thetaEdit = findobj(new, 'tag', 'thetaEdit');
h_chiEdit = findobj(new, 'tag', 'chiEdit');
h_chiRotEdit = findobj(new, 'tag', 'chiRotEdit');
h_button = findobj(new, 'tag', 'button');

%% defaults
% Dolan recommends doing after combining

obj = get(mainFigure, 'UserData');
set(h_edit, 'Value', num2str(obj.results.thetaResolution));
set(h_check, 'Value', obj.results.average);

set(h_thetaEdit, 'Value', '0.2');
set(h_chiEdit, 'Value', '0.2');
set(h_chiRotEdit, 'Value', '0');

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

set(h_thetaEdit, 'ValueChangedFcn', {@cakeEdit, h_thetaEdit});
set(h_chiEdit, 'ValueChangedFcn', {@cakeEdit, h_chiEdit});
set(h_chiRotEdit, 'ValueChangedFcn', {@cakeRotEdit, h_chiRotEdit});
set(h_button, 'ButtonPushedFcn', {@cakeButton, mainFigure, h_thetaEdit, ...
    h_chiEdit, h_chiRotEdit});

end

function analysisEdit(src, event, mainFigure, h_edit)

newVal = editExtract(h_edit);
obj = get(mainFigure, 'UserData');

if isnan(newVal)
    newVal = obj.results.thetaResolution;
end

updateFromEdit(mainFigure, newVal, 'results', 'thetaResolution', ...
    h_edit, false);

end

function analysisCheck(src, event, mainFigure, h_check)

newVal = logical(get(h_check, 'Value'));
obj = get(mainFigure, 'UserData');
obj = changeObject(obj, 'results', 'average', newVal);
set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure, 'results');

end

function cakeEdit(src, event, h_edit)

newVal = editExtract(h_edit);
if isnan(newVal)
    newVal = 0.2;
end
h_edit.Value = num2str(newVal);

end

function cakeRotEdit(src, event, h_edit)

newVal = editExtract(h_edit);
if isnan(newVal)
    newVal = 0;
end
h_edit.Value = num2str(newVal);

end

function cakeButton(src, event, mainFigure, h_theta, h_chi, h_rot)
obj = get(mainFigure, 'UserData');
obj = generateCake(obj, editExtract(h_theta), editExtract(h_chi), ...
    editExtract(h_rot));
set(mainFigure, 'UserData', obj);
end
