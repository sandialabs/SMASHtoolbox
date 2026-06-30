% DENNIS (Diffraction Experiment desigN and aNalysIS)
%
% Journal papers: https://doi.org/10.1088/1748-0221/19/07/P07030
%                 https://doi.org/10.1063/5.0267671
%
% Created by Nathan Brown (Sandia National Laboratories)
%
function DENNIS(pixels)

%% System and input handling

ver = version('-release');
yr = str2double(ver(1:end-1));
if yr < 2025 % much faster than checking graphics rendering through SMASH
    legpath = fullfile(smashroot, 'programs', 'legacy', 'DENNIS_Legacy');
    addpath(legpath);
    DENNIS_Legacy;
    return
elseif yr == 2025 && strcmp(ver(end), 'a')
    fprintf(['Some DENNIS graphics do not render properly in 2025a.\n', ...
        'It is recommended that you update to the latest MATLAB.\n']);
end

if nargin < 1
    pixels = 16;
end
calfont.set('',pixels);

%% Main GUI

% generate GUI and make category buttons

cb = SMASH.MUI2.ComponentBox('hide');
setGap(cb, [20 15]);
buttonWidth = 10;

h = addMessage(cb, buttonWidth, 2);
h.Text = 'Options:';
h.FontWeight = 'Bold';
h.FontSize = round(1.6*pixels);

buttonNames = {'Crystal', 'X-ray Source', 'Detector', 'Calibration', ...
    'Prediction', 'Simulation', 'Analysis'};
newRow(cb);
setFont(cb, '', pixels);
h = addButton(cb, buttonWidth, numel(buttonNames));
for ii = 1:numel(h)
    h(ii).Text = buttonNames{ii};
    h(ii).Tag = strtok(h(ii).Text, ' -');
end

newRow(cb);
buttonWidth = 4;
h = addButton(cb, buttonWidth);
h.Text = 'Import';
h.Tag = h.Text;
h = addButton(cb, buttonWidth);
h.Text = 'Export';
h.Tag = h.Text;

[parent,new,fig]=combine(cb,[],'hide');
fig.Name = 'Diffraction Experiment desigN and aNalysIS';

% set callbacks

[~, basePath] = strtok(fliplr(mfilename('fullpath')),'/\');
basePath = fliplr(basePath);
path1 = fullfile(basePath, 'helpers');
path2 = fullfile(basePath, 'dennisCallbacks');
path3 = fullfile(basePath, 'sharedCallbacks');
addpath(path1, path2, path3);

h = guihandles(parent(1));
set(h.Crystal, 'ButtonPushedFcn', @crystalDlg);
set(h.X, 'ButtonPushedFcn', @sourceDlg);
set(h.Detector, 'ButtonPushedFcn', @detectorDlg);
set(h.Calibration, 'ButtonPushedFcn', @calibrationDlg);
set(h.Prediction, 'ButtonPushedFcn', @predictionDlg);
set(h.Simulation, 'ButtonPushedFcn', @simulationDlg);
set(h.Analysis, 'ButtonPushedFcn', @analysisDlg);
set(h.Import, 'ButtonPushedFcn', @importDlg);
set(h.Export, 'ButtonPushedFcn', @exportDlg);
set(fig, 'CloseRequestFcn', @closeDennis);

% set up GUI axes

ax = axes(parent(2),'Units','normalized','OuterPosition',[0 0 1 1]);
view(ax, 21, 13);
axis(ax, 'equal');
box(ax, 'off');
hold(ax, 'on');
xlabel('x (mm)'); ylabel('y (mm)'); zlabel('z (mm)');
colormap(ax, parula);
ax.InteractionOptions.DatatipsSupported = 'off';
if yr > 2025
    ax.Toolbar.Expanded = 'on'; % introduced in 2026a
end

% initiate GUI operation

fig.UserData = SMASH.Xray.XRD;
fig.UserData.externalUserData.version = ver;
updatePlotPredictionAnalysis(fig);
figure(fig);

% address axes issues noticed in 2026a

ax.Toolbar.Visible = 'on';
ax.Toolbar.SelectionChangedFcn = @reShowToolbar;

end