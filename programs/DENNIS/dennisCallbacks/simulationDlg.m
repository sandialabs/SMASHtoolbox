function simulationDlg(src, event)

%% build cb

[cb, mainFigure, ex] = createCB(src, mfilename);
if ex
    return
end
setName(cb, 'Simulation Parameters');

% general

h_generalLabel = addMessage(cb);
h_generalLabel.Text = 'General';
h_generalLabel.FontWeight = 'Bold';
h_generalLabel.FontSize = 20;

setGap(cb, [10 0]);
newRow(cb);
h_generalEdit = [addEdit(cb, 5) addEdit(cb, 5) addEdit(cb, 5)];
h_generalEdit(1).Text = 'Max hkl';
h_generalEdit(3).Text = 'Sim Size';
h_generalEdit(5).Text = 'Pixel Num';

newRow(cb);
h_generalCheck = addCheckbox(cb, 20);
h_generalCheck.Text = ' Uniform Intensity?';

newRow(cb);
h_normalizeCheck = addCheckbox(cb, 20);
h_normalizeCheck.Text = ' Normalized Intensity?';
setGap(cb, [10 10]);

% mosaicity

newRow(cb);
h_mosaicityLabel = addMessage(cb);
h_mosaicityLabel.Text = 'Mosaicity (± deg)';
h_mosaicityLabel.FontWeight = 'Bold';
h_mosaicityLabel.FontSize = 20;

setGap(cb, [10 0]);
newRow(cb);
h_mosaicityEdit = [addEdit(cb, 3) addEdit(cb, 3) addEdit(cb, 3)];
h_mosaicityEdit(1).Text = 'a';
h_mosaicityEdit(3).Text = 'b';
h_mosaicityEdit(5).Text = 'c';

setGap(cb, [10 1]);
newRow(cb);
h_mosaicitySystemRadio = addRadio(cb, [2 2], 2, 'h', 'off');
h_mosaicitySystemRadio(1).Text = 'abc';
h_mosaicitySystemRadio(2).Text = 'xyz';

setGap(cb, [10 0]);
newRow(cb);
h_mosaicityDistributionRadio = addRadio(cb, [5 5], 2, 'h', 'off');
h_mosaicityDistributionRadio(1).Text = 'Gaussian';
h_mosaicityDistributionRadio(2).Text = 'Uniform';
setGap(cb, [10 10]);

% beam divergence

newRow(cb);
h_divergenceLabel = addMessage(cb);
h_divergenceLabel.Text = 'Beam Divergence';
h_divergenceLabel.FontWeight = 'Bold';
h_divergenceLabel.FontSize = 20;

setGap(cb, [10 0]);
newRow(cb);
h_divergenceEdit = addEdit(cb, 8);
h_divergenceEdit(1).Text = 'Half-Angle (deg)';

setGap(cb, [10 10]);
newRow(cb);
h_divergenceRadio = addRadio(cb, [5 5], 2, 'h', 'off');
h_divergenceRadio(1).Text = 'Gaussian';
h_divergenceRadio(2).Text = 'Uniform';

% gaussian spread

newRow(cb);
h_spreadLabel = addMessage(cb);
h_spreadLabel.Text = 'Gaussian Spread';
h_spreadLabel.FontWeight = 'Bold';
h_spreadLabel.FontSize = 20;

setGap(cb, [10 0]);
newRow(cb);
h_spreadEdit = addEdit(cb, 8);
h_spreadEdit(1).Text = 'Half-Angle (deg)';
setGap(cb, [10 10]);

% display

newRow(cb);
h_displayLabel = addMessage(cb);
h_displayLabel.Text = 'Display';
h_displayLabel.FontWeight = 'Bold';
h_displayLabel.FontSize = 20;

setGap(cb, [10 0]);
newRow(cb);
h_displayLim = [addEdit(cb, 5) addEdit(cb, 5)];
h_displayLim(1).Text = 'Min';
h_displayLim(3).Text = 'Max';
setGap(cb, [10 10]);

newRow(cb);
h_displaySliderLabel = addMessage(cb);
h_displaySliderLabel.Text = 'Transparency';
setGap(cb, [10 0]);
newRow(cb);
h_displaySlider = [addSlider(cb, [0 10]), addEdit(cb, [0 3])];
h_displaySlider(3) = [];
setGap(cb, [10 10]);

newRow(cb);
h_displayImageCheck = addCheckbox(cb, 4);
h_displayImageCheck.Text = ' Image?';
h_displayLabelsCheck = addCheckbox(cb, 4);
h_displayLabelsCheck.Text = ' Labels?';
h_displayCurrentCheck = addCheckbox(cb, 5);
h_displayCurrentCheck.Text = ' Updated?';

% simulate

setGap(cb, [10 10]);
newRow(cb);
h_simulateButton = addButton(cb, 5);
h_simulateButton.Text = 'Simulate';

% finalize and position cb

fit(cb)
locate(cb, 'West', mainFigure);
show(cb);

%% defaults

obj = get(mainFigure, 'UserData');
objsim = obj.simulation;

set(h_generalEdit(2), 'Value', num2str(objsim.max_hkl));
set(h_generalEdit(4), 'Value', sprintf('%.0g',objsim.simulationSize));
set(h_generalEdit(6), 'Value', sprintf('%.0g',objsim.pixelNum));
set(h_generalCheck(1), 'Value', objsim.uniformSpotIntensity);
set(h_normalizeCheck(1), 'Value', objsim.normalizedSpotIntensity);

set(h_mosaicityEdit(2), 'Value', num2str(objsim.mosaicity(1)));
set(h_mosaicityEdit(4), 'Value', num2str(objsim.mosaicity(2)));
set(h_mosaicityEdit(6), 'Value', num2str(objsim.mosaicity(3)));

if strcmpi(objsim.mosaicitySystem, 'abc')
    str = 'abc';
else
    set(h_mosaicitySystemRadio(2), 'Value', 1);
    str = 'xyz';
end
set(h_mosaicityEdit(1), 'Text', str(1));
set(h_mosaicityEdit(3), 'Text', str(2));
set(h_mosaicityEdit(5), 'Text', str(3));
if ~strcmpi(objsim.mosaicityDistribution, 'normal')
    set(h_mosaicityDistributionRadio(2), 'Value', 1);
end

set(h_divergenceEdit(2), 'Value', num2str(objsim.beamDivergenceHalfAngle));
if ~strcmpi(objsim.beamDivergenceDistribution, 'normal')
    set(h_divergenceRadio(2), 'Value', 1);
end

set(h_spreadEdit(2), 'Value', num2str(objsim.gaussianSpreadHalfAngle));

set(h_displaySlider(2), 'Limits', [0 1]);
set(h_displaySlider(2), 'Value', obj.simulation.faceAlpha);
set(h_displaySlider(3), 'Value', sprintf('%.2f',obj.simulation.faceAlpha));
set(h_displayImageCheck, 'Value', objsim.displayInDENNIS)
set(h_displayLabelsCheck, 'Value', objsim.displayLabelsInDENNIS)
set(h_displayCurrentCheck, 'Enable', 'off');

set(h_displayLim(2), 'Tag', 'lim1');
set(h_displayLim(4), 'Tag', 'lim2');
set(h_displaySlider(2), 'Tag', 'slider')
set(h_displaySlider(3), 'Tag', 'edit')
set(h_displayImageCheck, 'Tag', 'image')
set(h_displayLabelsCheck, 'Tag', 'labels')
set(h_displayCurrentCheck, 'Tag', 'current');

% update other values via helper

updatePlotPredictionAnalysis(mainFigure);

%% callback assignments

h = [h_generalEdit(2:2:6), h_generalCheck, h_mosaicityEdit(2:2:6), ...
    h_divergenceEdit(2), h_spreadEdit(2), h_normalizeCheck];
set(h, 'ValueChangedFcn', {@paramEdit, mainFigure, h, h_displayCurrentCheck});
set(get(h_mosaicitySystemRadio(1), 'parent'), 'SelectionChangedFcn', {@radioChange, mainFigure, ...
    h_mosaicitySystemRadio, 'mosaicitySystem', h_displayCurrentCheck, ...
    h_mosaicityEdit});
set(get(h_mosaicityDistributionRadio(1), 'parent'), 'SelectionChangedFcn', {@radioChange, mainFigure, ...
    h_mosaicityDistributionRadio, 'mosaicityDistribution', h_displayCurrentCheck});
set(get(h_divergenceRadio(1), 'parent'), 'SelectionChangedFcn', {@radioChange, mainFigure, ...
    h_divergenceRadio, 'beamDivergenceDistribution', h_displayCurrentCheck});

set(findobj(h_displayLim, 'type', 'uieditfield'), 'ValueChangedFcn', {@limChange, mainFigure, h_displayLim});
set(h_displayImageCheck, 'ValueChangedFcn', {@displayImage, mainFigure});
set(h_displayLabelsCheck, 'ValueChangedFcn', {@displayLabels, mainFigure});

set(h_displaySlider(2), 'ValueChangingFcn', ...
    @(src, event)displaySlider(src, event, mainFigure, ...
    h_displaySlider(3)));
set(h_displaySlider(2), 'ValueChangedFcn', ...
    @(src, event)displaySlider(src, event, mainFigure, ...
    h_displaySlider(3)));
set(h_displaySlider(3), 'ValueChangedFcn', {@displaySliderEdit, ...
    mainFigure, h_displaySlider});

set(h_simulateButton, 'ButtonPushedFcn', {@simulate, mainFigure, ...
    h_displayCurrentCheck, h_displayImageCheck});

end

%% callbacks

function paramEdit(src, event, mainFigure, h, h_displayCurrentCheck)

updateFromEdit(mainFigure, editExtract(h(1)), 'simulation', 'max_hkl', ...
    h(1), false);
updateFromEdit(mainFigure, editExtract(h(5:7)), 'simulation', 'mosaicity', ...
    h(5:7), false);
updateFromEdit(mainFigure, editExtract(h(8)), 'simulation', 'beamDivergenceHalfAngle', ...
    h(8), false);
updateFromEdit(mainFigure, editExtract(h(9)), 'simulation', 'gaussianSpreadHalfAngle', ...
    h(9), false);

obj = get(mainFigure, 'UserData');

obj = changeObject(obj, 'simulation', 'uniformspotintensity', ...
    logical(get(h(4), 'Value')));
obj = changeObject(obj, 'simulation', 'normalizedspotintensity', ...
    logical(get(h(10), 'Value')));
if isprop(src, 'Text') && contains(src.Text, 'Normalized')
    obj.externalUserData.simLim = 'reset';
end
obj = changeObject(obj, 'simulation', 'simulationSize', editExtract(h(2)));
set(h(2), 'Value', sprintf('%.0g',obj.simulation.simulationSize))
obj = changeObject(obj, 'simulation', 'pixelNum', editExtract(h(3)));
set(h(3), 'Value', sprintf('%.0g',obj.simulation.pixelNum))

set(mainFigure, 'UserData', obj);
set(h_displayCurrentCheck, 'Value', obj.simulation.current)

end

function radioChange(src, event, mainFigure, h_radio, subCategory, ...
    h_displayCurrentCheck, varargin)

obj = get(mainFigure, 'UserData');
ind = [h_radio.Value];
str = get(h_radio(ind),'Text');

if strcmpi(subCategory, 'mosaicitySystem')
    set(varargin{1}(1), 'Text', str(1));
    set(varargin{1}(3), 'Text', str(2));
    set(varargin{1}(5), 'Text', str(3));
    obj = changeObject(obj, 'simulation', subCategory, str);
else
    switch str
        case 'Gaussian'
            obj = changeObject(obj, 'simulation', subCategory, 'normal');
        case 'Uniform'
            obj = changeObject(obj, 'simulation', subCategory, 'uniform');
    end
end

set(mainFigure, 'UserData', obj);
set(h_displayCurrentCheck, 'Value', obj.simulation.current)

end

function limChange(src, event, mainFigure, h)
newVal = editExtract(h);
obj = get(mainFigure, 'UserData');
if any(isnan(newVal))
    newVal = [0 1];
end
obj.externalUserData.simLim = newVal;
set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure, 'detector');
end

function simulate(src, event, mainFigure, h_displayCurrentCheck, ...
    h_displayImageCheck)
set(h_displayCurrentCheck, 'Value', false); drawnow;
set(h_displayImageCheck, 'Value', true);
obj = changeObject(get(mainFigure, 'UserData'), 'simulation', ...
    'displayInDENNIS', true);
obj = runSimulation(obj);
set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure, 'detector');
end

function displayImage(src, event, mainFigure)
obj = changeObject(get(mainFigure, 'UserData'), 'simulation', ...
    'displayindennis', get(src, 'Value'));
set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure, 'detector');
end

function displayLabels(src, event, mainFigure)
obj = changeObject(get(mainFigure, 'UserData'), 'simulation', ...
    'displaylabelsindennis', get(src, 'Value'));
set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure, 'detector');
end

function displaySlider(src, event, mainFigure, h_edit)

sliderVal = event.Value;
set(h_edit, 'Value', num2str(sliderVal))

obj = get(mainFigure, 'UserData');
obj = changeObject(obj, 'simulation', 'faceAlpha', sliderVal);
set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure, 'detector');

end

function displaySliderEdit(src, event, mainFigure, h_slider)

sliderVal = editExtract(h_slider(3));
updateFromEdit(mainFigure, sliderVal, 'simulation', 'faceAlpha', ...
    h_slider(3), false);
updatePlotPredictionAnalysis(mainFigure, 'detector');

obj = get(mainFigure, 'UserData');
set(h_slider(2), 'Value', obj.simulation.faceAlpha);

end











