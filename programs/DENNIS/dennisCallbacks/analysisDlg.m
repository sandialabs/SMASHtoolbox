function analysisDlg(src, event)

%% build cb

[cb, mainFigure, ex] = createCB(src, mfilename);
if ex
    return
end
name = 'Powder Diffraction Image Analysis';

% parameters

h_label = addMessage(cb);
h_label.Text = 'Parameters';
h_label.FontWeight = 'Bold';
h_label.FontSize = 20;

setGap(cb, [10 0]);
newRow(cb);
h_edit = addEdit(cb, 5);
h_edit(1).Text = 'Res (deg)';

newRow(cb);
h_check = addCheckbox(cb, 15);
h_check.Text = ' Average along arc?';

%% build combined

[new, fig, ax] = createCombined(mainFigure, cb, name);

h_edit = findobj(new, 'type', 'uieditfield');
h_check = findobj(new, 'type', 'uicheckbox');

set(fig, 'Units', 'normalized');
set(fig, 'Position', [0.1 0.1 0.6 0.5]);
movegui(fig, 'center');
set(fig, 'Units', 'pixels');

%% defaults
% Dolan recommends doing after combining

obj = get(mainFigure, 'UserData');
set(h_edit, 'Value', num2str(obj.results.thetaResolution));
set(h_check, 'Value', obj.results.average);

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