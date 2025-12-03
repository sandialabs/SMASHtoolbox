function sourceDlg(src, event)

%% build cb

[cb, mainFigure, ex] = createCB(src, mfilename);
if ex
    return
end
setName(cb, 'X-ray Source');

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

% rotate

newRow(cb);
h_orLabel = addMessage(cb);
h_orLabel.Text = 'Rotate (deg)';
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
setGap(cb, [10 10]);

newRow(cb);
h_orCheck = addCheckbox(cb, 20);
h_orCheck.Text = ' Also rotate detector?';

% x-ray vector

newRow(cb);
h_vecLabel = addMessage(cb);
h_vecLabel.Text = 'Vector (mm)';
h_vecLabel.FontWeight = 'Bold';
h_vecLabel.FontSize = 20;

setGap(cb, [10 0]);
newRow(cb);
h_vecEdit = [addEdit(cb, 3) addEdit(cb, 3) addEdit(cb, 3)];
h_vecEdit(1).Text = 'x';
h_vecEdit(3).Text = 'y';
h_vecEdit(5).Text = 'z';
setGap(cb, [10 10]);

% radiation

newRow(cb);
h_radLabel = addMessage(cb);
h_radLabel.Text = 'Radiation';
h_radLabel.FontWeight = 'Bold';
h_radLabel.FontSize = 20;

setGap(cb, [10 0]);
newRow(cb);
h_radValLabel = addMessage(cb, 3);
h_radValLabel.Text = 'Value';
setGap(cb, [0 0]);
h_radEditWaveVal = [addEdit(cb, 8) addEdit(cb, 8)];
h_radEditWaveVal(1).Text = 'Wavelength (A)';
h_radEditWaveVal(3).Text = 'Energy (keV)';

newRow(cb);
h_radDistLabel = addMessage(cb, 3);
h_radDistLabel.Text = 'Dist';
h_radEditWaveDist = [addEdit(cb, [0 8]) addEdit(cb, [0 8])];

setGap(cb, [0 10]);
newRow(cb);
h_dummy = addMessage(cb, 3);
h_dummy.Text = '';
h_radButton = addButton(cb, 4);
h_radButton.Text = 'Load';

newRow(cb);
h_radEditPol = [addEdit(cb, 5) addEdit(cb, 5)];
h_radEditPol(1).Text = 'K';
h_radEditPol(3).Interpreter = 'latex';
h_radEditPol(3).Text = '2θ$_\mathrm{M}$ (deg)';

% finalize and position cb

fit(cb)
locate(cb, 'West', mainFigure);
show(cb);

%% defaults

obj = get(mainFigure, 'UserData');
obj = obj.source;

set(h_posSlider(2), 'Value', 0);
set(h_posSlider(3), 'Value', '0');
set(h_posSlider(3), 'Enable', 'off');
set(h_posSlider(2), 'Limits', [-1 1]);
set(h_posSlider(2), 'MajorTicks', -1:.5:1);
set(h_posEdit(2), 'Tag', 'xPos');
set(h_posEdit(4), 'Tag', 'yPos');
set(h_posEdit(6), 'Tag', 'zPos');

set(h_orSlider(2), 'Value', 0);
set(h_orSlider(3), 'Value', '0');
set(h_orSlider(3), 'Enable', 'off');
set(h_orSlider(2), 'Limits', [-1 1]);
set(h_orSlider(2), 'MajorTicks', -1:.5:1);
set(h_orEdit(2), 'Tag', 'xRot');
set(h_orEdit(4), 'Tag', 'yRot');
set(h_orEdit(6), 'Tag', 'zRot');

set(h_vecEdit(2), 'Tag', 'xs0');
set(h_vecEdit(4), 'Tag', 'ys0');
set(h_vecEdit(6), 'Tag', 'zs0');

set(h_radEditWaveVal(2), 'Tag', 'lambda');
set(h_radEditWaveVal(4), 'Tag', 'E');

set(h_radEditWaveDist(2), 'Tag', 'lambdaDistribution');
set(h_radEditWaveDist(4), 'Tag', 'EDistribution');

set(h_radEditPol(2), 'Value', num2str(obj.K));
set(h_radEditPol(4), 'Value', num2str(obj.twoThetaM));

% update tagged values in dlg

updatePlotPredictionAnalysis(mainFigure, 'source');

%% callback assignments

% close

category = 'source';
set(cb.Figure, 'CloseRequestFcn', {@closeDlg, mainFigure, category, ...
    {'location'}});

% position

subcategory = 'location';
set(h_posSlider(2), 'ValueChangingFcn', ...
    @(src,event)xyzSliderListener(src, event, mainFigure, h_posSlider(3), ...
    h_posSliderRadio, h_posEdit, category, subcategory));
set(h_posSlider(2), 'ValueChangedFcn', {@xyzSliderRelease, mainFigure, h_posSlider(3), ...
    h_posSliderRadio, h_posEdit, category, subcategory, ...
    {h_orSlider(2), h_orSlider(3)}, {'Value', 'Value'}, {0, '0'}});
set(get(h_posSliderRadio(1), 'parent'), 'SelectionChangedFcn', ...
    @(src, event)resetReference(mainFigure, ...
    h_posSlider, category, subcategory));
set(findobj(h_posEdit, 'Type', 'uieditfield'), 'ValueChangedFcn', {@changeEdit, mainFigure, h_posEdit, ...
    h_posSlider, category, subcategory, ...
    {h_orSlider(2), h_orSlider(3)}, {'Value', 'Value'}, {0, '0'}});

% rotate

subcategory = 'rotate';
set(h_orSlider(2), 'ValueChangingFcn', ...
    @(src,event)xyzSliderListener(src, event, mainFigure, h_orSlider(3), ...
    h_orSliderRadio, h_orEdit, category, subcategory, h_orCheck));
set(h_orSlider(2), 'ValueChangedFcn', {@xyzSliderRelease, mainFigure, h_orSlider(3), ...
    h_orSliderRadio, h_orEdit, category, subcategory, h_orCheck});
set(get(h_orSliderRadio(1), 'parent'), 'SelectionChangedFcn', ...
    @(src, event)resetReference(mainFigure, ...
    h_orSlider, category, subcategory));
set(findobj(h_orEdit, 'Type', 'uieditfield'), 'ValueChangedFcn', {@changeEdit, mainFigure, h_orEdit, ...
    h_orSlider, category, subcategory, h_orCheck});

% vector

set(findobj(h_vecEdit, 'Type', 'uieditfield'), 'ValueChangedFcn', {@sourceVectorEdit, mainFigure, h_vecEdit});

% radiation

set(h_radEditWaveVal(2), 'ValueChangedFcn', {@sourceLambdaEdit, mainFigure});
set(h_radEditWaveVal(4), 'ValueChangedFcn', {@sourceEEdit, mainFigure});
set(h_radEditWaveDist(2), 'ValueChangedFcn', {@sourceLambdaDistributionEdit, mainFigure});
set(h_radEditWaveDist(4), 'ValueChangedFcn', {@sourceEDistributionEdit, mainFigure});
set(h_radEditPol(2), 'ValueChangedFcn', {@sourceKEdit, mainFigure});
set(h_radEditPol(4), 'ValueChangedFcn', {@sourcetwoThetaMEdit, mainFigure});
set(h_radButton, 'ButtonPushedFcn', {@sourceRadButton, mainFigure})


end

%% callbacks specific to this cb

function sourceVectorEdit(src, event, mainFigure ,h)
updateFromEdit(mainFigure, editExtract(h), 'source', 's0', ...
    h, true);
end

function sourceKEdit(src, event, mainFigure)
updateFromEdit(mainFigure, editExtract(src), 'source', 'K', ...
    src, true);
end

function sourcetwoThetaMEdit(src, event, mainFigure)
updateFromEdit(mainFigure, editExtract(src), 'source', 'twoThetaM', ...
    src, true);
end

function sourceLambdaEdit(src, event, mainFigure)
updateFromEdit(mainFigure, editExtract(src), 'source', 'lambda', ...
    src, true);
end

function sourceEEdit(src, event, mainFigure)
updateFromEdit(mainFigure, editExtract(src), 'source', 'E', ...
    src, true);
end

function sourceLambdaDistributionEdit(src, event, mainFigure)

lambdaStr = split(get(src, 'Value'), '-');
lambdaStr = split(lambdaStr, '-');
dist = sscanf(lambdaStr{1}, '%g', 1);
if length(lambdaStr) > 1
    dist = [dist, sscanf(lambdaStr{2}, '%g', 1)];
end

obj = get(mainFigure, 'UserData');
obj = changeObject(obj, 'source', 'lambdaDistribution', dist);
set(mainFigure, 'UserData', obj);

updatePlotPredictionAnalysis(mainFigure);

end

function sourceEDistributionEdit(src, event, mainFigure)

EStr = split(get(src, 'Value'), '-');
EStr = split(EStr, '-');
dist = sscanf(EStr{1}, '%g', 1);
if length(EStr) > 1
    dist = [dist, sscanf(EStr{2}, '%g', 1)];
end

obj = get(mainFigure, 'UserData');
obj = changeObject(obj, 'source', 'EDistribution', dist);
set(mainFigure, 'UserData', obj);

updatePlotPredictionAnalysis(mainFigure);

end

function sourceRadButton(src, event, mainFigure)

[file, path] = uigetfile('*.xls;*.xlsx;*.csv;*.mat', ...
    'Select distribution file');
if isnumeric(file)
    return
end
input = fullfile(path, file);
answ = questdlg('Wavelength (A) or Energy (keV)?', 'Distribution Type', ...
    'Wavelength (A)', 'Energy (keV)', 'Energy (keV)');
if isempty(answ)
    return
end
if contains(answ(1), 'W')
    choiceStr = 'lambdaDistribution';
else
    choiceStr = 'EDistribution';
end

[~, ~, ext] = fileparts(input);
if strcmpi(ext, '.mat')
    input = load(input);
    varNames = fieldnames(mat);
    if numel(varNames) < 1
        error('No variables found');
    elseif numel(varNames) > 1
        warning('Selecting first found variable');
    end
    input = input.(varNames{1});
end
obj = get(mainFigure, 'UserData');
obj = changeObject(obj, 'source', choiceStr, input);
set(mainFigure, 'UserData', obj);

updatePlotPredictionAnalysis(mainFigure);

end