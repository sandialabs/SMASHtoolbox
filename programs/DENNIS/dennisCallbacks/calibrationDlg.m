function calibrationDlg(src, event)

%% determine whether to create cb

mainFigure = ancestor(src, 'figure', 'toplevel');

% check for open calibration dlgs

if isappdata(mainFigure, 'calCrystalDlg')
    db = getappdata(mainFigure, 'calCrystalDlg');
    if isvalid(db) && ~isempty(findobj(db, 'Type', 'Axes'))
        figure(db);
        return
    end
elseif isappdata(mainFigure, 'calDetectorManualDlg')
    db = getappdata(mainFigure, 'calDetectorManualDlg');
    if isvalid(db) && ~isempty(findobj(db, 'Type', 'Axes'))
        figure(db);
        return
    end
end

% check for ga function

if ~license('test', 'GADS_Toolbox')
    errordlg('MATLAB Global Optimization Toolbox required for calibration')
    return
end

% check for image

obj = get(mainFigure, 'UserData');
if isnumeric(obj.detector.image)
    errordlg('Load and process detector image prior to calibration')
    return
end

%% create cb

[cb, ~, ex] = createCB(src, mfilename);
if ex
    return
end
setName(cb, 'Calibration Type');

% buttons

h_button = [addButton(cb, 10) addButton(cb, 10) addButton(cb, 5)];
h_button(1).Text = 'Detector (auto)';
h_button(2).Text = 'Detector (manual)';
h_button(3).Text = 'Crystal';

% finalize and position cb

fit(cb)
locate(cb, 'Center', mainFigure);
show(cb);

%% set callbacks

set(h_button(1), 'ButtonPushedFcn', {@calDetectorAuto, mainFigure});
set(h_button(2), 'ButtonPushedFcn', {@calDetectorManualDlg, mainFigure});
set(h_button(3), 'ButtonPushedFcn', {@calCrystalDlg, mainFigure});

end

%% callbacks

function calDetectorAuto(src, event, mainFigure)
close(ancestor(src,'figure'));
obj = get(mainFigure, 'UserData');
obj = changeObject(obj, 'calibration', 'type', 'detectorAuto');
obj = calROI(obj);
obj = calThresh(obj);
obj = calCC(obj);
obj = calPOI(obj);
[obj, score] = calSolve(obj);
fprintf('Final GA score of %d\n', score);
set(mainFigure, 'UserData', obj)
updatePlotPredictionAnalysis(mainFigure);
end




