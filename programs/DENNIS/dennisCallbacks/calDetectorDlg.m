function calDetectorDlg(src, event)

%% initial checks

% check for ga function

if ~license('test', 'GADS_Toolbox')
    errordlg('MATLAB Global Optimization Toolbox required for calibration')
    return
end

% check for image

mainFigure = ancestor(src, 'figure', 'toplevel');
obj = get(mainFigure, 'UserData');
if isnumeric(obj.detector.image)
    errordlg('Load and process detector image prior to calibration')
    return
end

%% build cb

[cb, ~, ex] = createCB(src, mfilename);
if ex
    return
end
name = 'Detector Calibration';

% roi selection

setGap(cb, [10 20]);
h = addMessage(cb);
h.Text = 'ROI Options';
h.FontWeight = 'Bold';
h.FontSize = 20;

setGap(cb, [10 0]);
newRow(cb);
h = addEdit(cb, 7);
h(1).Text = 'Filter σ';
h(2).Tag = h(1).Text;
h = addEdit(cb, 7);
h(1).Text = 'Valid Cutoff';
h(2).Tag = h(1).Text;

newRow(cb);
h = addEdit(cb, 7);
h(1).Text = 'Thresh Frac';
h(2).Tag = h(1).Text;
h = addEdit(cb, 7);
h(1).Text = 'Min Reg Size';
h(2).Tag = h(1).Text;
setGap(cb, [10 10]);

% poi selection

setGap(cb, [10 20]);
newRow(cb);
h = addMessage(cb);
h.Text = 'POI Options';
h.FontWeight = 'Bold';
h.FontSize = 20;

setGap(cb, [10 0]);
newRow(cb);
h = addEdit(cb, 7);
h(1).Text = 'Min Pt Dist';
h(2).Tag = h(1).Text;

% newRow(cb);
% h = addEdit(cb, 7);
% h(1).Text = 'Max Pt Num';
% h(2).Tag = h(1).Text;
h = addEdit(cb, 7);
h(1).Text = 'Int Cutoff';
h(2).Tag = h(1).Text;
setGap(cb, [10 10]);

% 
setGap(cb, [10 20]);
newRow(cb);
h = addMessage(cb);
h.Text = 'Selection Actions';
h.FontWeight = 'Bold';
h.FontSize = 20;

setGap(cb, [10 10]);
newRow(cb);
h = addButton(cb, 5);
h.Text = 'Undo';
h.Tag = h.Text;
h = addButton(cb, 5);
h.Text = 'Combine';
h.Tag = h.Text;
newRow(cb);
h = addButton(cb, 5);
h.Text = 'Manual';
h.Tag = h.Text;
h = addButton(cb, 5);
h.Text = 'Reset';
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

h_roiEditSigma = findobj(new, 'Tag', 'Filter σ');
h_roiEditValid = findobj(new, 'Tag', 'Valid Cutoff');
h_roiEditThresh = findobj(new, 'Tag', 'Thresh Frac');

h_poiEditSize = findobj(new, 'Tag', 'Min Reg Size');
h_poiEditDist = findobj(new, 'Tag', 'Min Pt Dist');
% h_poiEditNum = findobj(new, 'Tag', 'Max Pt Num');
h_poiEditCutoff = findobj(new, 'Tag', 'Int Cutoff');
h_poiButton = findobj(new, 'Tag', 'Manual');
h_poiUndoButton = findobj(new,'Tag','Undo');
h_poiCombineButton = findobj(new,'Tag','Combine');
h_poiResetButton = findobj(new, 'Tag', 'Reset');

h_calEditSize = findobj(new, 'Tag', 'Pop Size:');
h_calEditBounds = findobj(new, 'Tag', 'calEdit');
h_calButton = findobj(new, 'Tag', 'Solve');

%% set defaults

obj = get(mainFigure, 'UserData');
obj = changeObject(obj,'calibration','cc',[]);
obj = changeObject(obj,'calibration','poi',[]);
obj = changeObject(obj,'calibration','poiFitResidual',[]);

% previousPOI = [];
% if contains(obj.calibration.type, 'detector')
%     previousPOI = obj.calibration.poi;
% end
obj = changeObject(obj, 'calibration', 'type', 'detector');
% obj = calPOI(obj, previousPOI); % will probably put something like this back later

set(ax, 'FontSize', 16)
set(ax.Title,'Visible','on');
hold(ax, 'on')
view(obj.detector.image, 'show', ax, true);
setTitle(ax);
plotPOI(obj,ax);
axis(ax, 'equal');
delete(findobj(fig, 'type', 'colorbar'));
if str2double(mainFigure.UserData.externalUserData.version(1:end-1)) > 2025
    ax.Toolbar.Expanded = 'on'; % introduced in 2026a
end
ax.Toolbar.Visible = 'on';
ax.Toolbar.SelectionChangedFcn = @reShowToolbar;

set(h_roiEditSigma(1), 'Value', num2str(obj.calibration.opts.gaussianSigma));
set(h_roiEditValid(1), 'Value', num2str(obj.calibration.opts.validFilterCutoff));
set(h_roiEditThresh(1), 'Value', num2str(obj.calibration.opts.threshFrac));

set(h_poiEditSize(1), 'Value', num2str(obj.calibration.opts.minRegSize));
set(h_poiEditDist(1), 'Value', num2str(obj.calibration.opts.minPointDist));
% set(h_poiEditNum(1), 'Value', num2str(obj.calibration.opts.maxPointNum));
set(h_poiEditCutoff(1), 'Value', num2str(obj.calibration.opts.intCutoff));

set(h_calEditSize(1), 'Value', num2str(obj.calibration.opts.gaOpts.PopulationSize, '%.0g'));
set(h_calEditBounds(1), 'Value', num2str(obj.calibration.searchBounds(1)));
set(h_calEditBounds(2), 'Value', num2str(obj.calibration.searchBounds(2)));
set(h_calEditBounds(3), 'Value', num2str(obj.calibration.searchBounds(3)));
set(h_calEditBounds(4), 'Value', num2str(obj.calibration.searchBounds(4)));
set(h_calEditBounds(5), 'Value', num2str(obj.calibration.searchBounds(5)));
set(h_calEditBounds(6), 'Value', num2str(obj.calibration.searchBounds(6)));

%% set callbacks

set(h_roiEditSigma, 'ValueChangedFcn', {@changeOptEdit, mainFigure, h_roiEditSigma, ...
    'gaussianSigma'});
set(h_roiEditValid, 'ValueChangedFcn', {@changeOptEdit, mainFigure, h_roiEditValid, ...
    'validFilterCutoff'});
set(h_roiEditThresh, 'ValueChangedFcn', {@changeOptEdit, mainFigure, h_roiEditThresh, ...
    'threshFrac'});

set(h_poiEditSize, 'ValueChangedFcn', {@changeOptEdit, mainFigure, h_poiEditSize, ...
    'minRegSize'});
set(h_poiEditDist, 'ValueChangedFcn', {@changeOptEdit, mainFigure, h_poiEditDist, ...
    'minPointDist'});
% set(h_poiEditNum, 'ValueChangedFcn', {@changeOptEdit, mainFigure, h_poiEditNum, ...
    % 'maxPointNum'});
set(h_poiEditCutoff, 'ValueChangedFcn', {@changeOptEdit, mainFigure, h_poiEditCutoff, ...
    'intCutoff'});
set(h_poiButton, 'ButtonPushedFcn', {@pressManualButton, mainFigure, ax})
set(h_poiUndoButton, 'ButtonPushedFcn', {@pressUndoButton, mainFigure, ax})
set(h_poiCombineButton, 'ButtonPushedFcn', {@pressCombineButton, mainFigure, ax})
set(h_poiResetButton, 'ButtonPushedFcn', {@pressResetButton, mainFigure, ax})

set(h_calEditSize, 'ValueChangedFcn', {@changeCalEditSize, mainFigure, ...
    h_calEditSize});
set(h_calEditBounds, 'ValueChangedFcn', {@changeEdit, mainFigure, h_calEditBounds, ...
    nan, 'calibration', 'searchBounds'});
set(h_calButton, 'ButtonPushedFcn', {@pressCalButton, mainFigure})
set(ax,'ButtonDownFcn',{@pressFindButton, mainFigure, ax})

% show figure

figure(fig);

%% initial solve

obj = calFilter(obj);
plotPOI(obj,ax);
set(mainFigure, 'UserData', obj);

end

%% callback functions

function changeOptEdit(src, event, mainFigure, h, opt)
obj = get(mainFigure, 'UserData');
obj = changeObject(obj, 'calibration', 'opts', opt, editExtract(h));
set(h(1), 'Value', num2str(obj.calibration.opts.(opt)));
if strcmpi(opt, 'gaussianSigma') || strcmpi(opt, 'validFilterCutoff') || ...
        strcmpi(opt, 'threshFrac')
    obj = calFilter(obj);
end
set(mainFigure, 'UserData', obj);
end

function pressFindButton(source, event, mainFigure, ax)
% find poi based on click
loc = source.CurrentPoint(1,1:2);
obj = get(mainFigure, 'UserData');
obj = calCC(obj,loc);
obj = calPOI(obj);
set(mainFigure,'UserData',obj);
plotPOI(obj,ax);
end

function pressManualButton(source, event, mainFigure, ax)
% manually edit calibration points
delete(findobj(ax,'Type','Line'));
set(ax,'ButtonDownFcn','');
title(ax, 'Construct ROIs in increasing 2θ order')
obj = get(mainFigure, 'UserData');
obj = changeObject(obj, 'calibration', 'opts', 'poiType', 'manual');
obj = calPOI(obj, ax);
set(mainFigure, 'UserData', obj);
plotPOI(obj,ax);
end

function pressUndoButton(source, event, mainFigure, ax)
% undo last selection
obj = get(mainFigure, 'UserData');
if contains(obj.calibration.opts.poiType,'manual')
    errordlg('Not available after manual selection')
    return
end
if isempty(obj.calibration.poi)
    return
end
poi = obj.calibration.poi;
cc = obj.calibration.cc;
poiRes = obj.calibration.poiFitResidual;
poi(:,:,end) = [];
cc.NumObjects = cc.NumObjects-1;
cc.PixelIdxList(end) = [];
cc.NumPixels(end) = [];
poiRes(end) = [];
obj = changeObject(obj,'calibration','poi',poi);
obj = changeObject(obj,'calibration','cc',cc);
obj = changeObject(obj,'calibration','poifitresidual',poiRes);
plotPOI(obj,ax);
set(mainFigure, 'UserData', obj);
end

function pressCombineButton(source, event, mainFigure, ax)
% graphically combine poi
obj = get(mainFigure, 'UserData');
if contains(obj.calibration.opts.poiType,'manual')
    errordlg('Not available after manual selection')
    return
end
if size(obj.calibration.poi,3) < 2
    errordlg('Nothing to combine');
    return
end
title(ax,'Lasso the POI of rings you wish to combine');
set(ax,'ButtonDownFcn','');
set(mainFigure,'UserData',obj);
obj = calCombine(obj,ax);
if isvalid(ax) % false if user closes figure
    set(ax,'ButtonDownFcn',{@pressFindButton, mainFigure, ax})
    setTitle(ax);
    plotPOI(obj,ax);
end
set(mainFigure,'UserData',obj);
end

function pressResetButton(source,event,mainFigure,ax)
obj = get(mainFigure,'UserData');
obj = changeObject(obj,'calibration','cc',[]);
obj = changeObject(obj,'calibration','poi',[]);
obj = changeObject(obj,'calibration','poiFitResidual',[]);
obj = changeObject(obj,'calibration','opts','poitype','auto');
plotPOI(obj,ax);
setTitle(ax);
set(mainFigure,'UserData',obj);
end

function changeCalEditSize(src, event, mainFigure, h)
obj = get(mainFigure, 'UserData');
obj = changeObject(obj, 'calibration', 'opts', 'gaPopulation', editExtract(h));
set(h(1), 'Value', num2str(obj.calibration.opts.gaOpts.PopulationSize, '%.0g'));
set(mainFigure, 'UserData', obj);
end

function pressCalButton(src, event, mainFigure)
uistack(ancestor(src,'figure'), 'bottom');
obj = get(mainFigure, 'UserData');
[obj, score] = calSolve(obj);
fprintf('Final GA score of %d\n', score);
set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure);
figure(mainFigure);

% update detectorDlg (not doing yet in auto cal b/c we think we're going to
% make one combined cal dialog)

badFlag = true;
if isappdata(mainFigure, 'detectorDlg')
    db = getappdata(mainFigure, 'detectorDlg');
    if isvalid(db)
        if ishandle(db.Figure)
            badFlag = false;
        end
    end
end
if badFlag
    return
end

db = db.Figure;

set(findobj(db, 'Tag', 'lx'), 'Value', ...
    num2str(obj.detector.location(1)));
set(findobj(db, 'Tag', 'ly'), 'Value', ...
    num2str(obj.detector.location(2)));
set(findobj(db, 'Tag', 'lz'), 'Value', ...
    num2str(obj.detector.location(3)));
set(findobj(db, 'Tag', 'ls'), 'Value', 0);
set(findobj(db, 'Tag', 'lt'), 'Value', '0');

set(findobj(db, 'Tag', 'rx'), 'Value', ...
    num2str(obj.detector.orientation(1)));
set(findobj(db, 'Tag', 'ry'), 'Value', ...
    num2str(obj.detector.orientation(2)));
set(findobj(db, 'Tag', 'rz'), 'Value', ...
    num2str(obj.detector.orientation(3)));
set(findobj(db, 'Tag', 'rs'), 'Value', 0);
set(findobj(db, 'Tag', 'rt'), 'Value', '0');

end

function plotPOI(obj,ax)
delete(findobj(ax,'Type','Line'));
colors = [
    255 0 0
    0 0 0
    ] / 255;
colororder(colors);
ax.ColorOrderIndex = 1;
if ~isempty(obj.calibration.poi)
    for ii = 1:size(obj.calibration.poi,3)
        plot(ax, obj.calibration.poi(:,1,ii), obj.calibration.poi(:,2,ii), ...
            '*', 'markersize', 5, 'linewidth', 1);
    end
end
set(get(ax,'Children'),'HitTest','off'); % to enable axes clicking
end

function setTitle(ax)
title(ax,'Click rings in increasing 2θ order, in multiple regions as necessary');
end



