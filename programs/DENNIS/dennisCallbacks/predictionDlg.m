function predictionDlg(src, event)

%% build cb

[cb, mainFigure, ex] = createCB(src, mfilename);
if ex
    return
end
setName(cb, 'Prediction');

% prediction

h_label = addMessage(cb);
h_label.Text = 'Prediction';
h_label.FontWeight = 'Bold';
h_label.FontSize = 20;

newRow(cb);
h_radio = addRadio(cb, [4 7], 2, 'h', 'off');
h_radio(1).Text = 'Powder';
h_radio(2).Text = 'Single-Crystal';
h_button = addButton(cb, 7);
h_button.Text = 'Make Figure';

setGap(cb, [10 0]);
newRow(cb);
h_edit = [addEdit(cb, 4) addEdit(cb, 4)];
h_edit(1).Text = 'Min I';
h_edit(3).Text = 'Max hkl';
setGap(cb, [10 10]);

newRow(cb);
h_table = addTable(cb, 5*ones(1,6), 10);
h_table(1).Text = '[ h k l ]';
h_table(2).Text = 'λ (A)';
h_table(3).Text = 'm';
h_table(4).Text = '2θ (°)';
h_table(5).Text = 'I';
h_table(6).Text = 'Show?';
h_table = h_table(7);

% finalize and position cb

fit(cb)
locate(cb, 'West', mainFigure)
show(cb);

%% defaults

obj = get(mainFigure, 'UserData');
objFilt = obj.externalUserData;
obj = obj.prediction;

if strcmpi(obj.type, 'single-crystal')
    set(h_radio(2), 'value', 1);
end

set(h_edit(2), 'Value', num2str(objFilt.min_I_show));
set(h_edit(4), 'Value', num2str(objFilt.max_hkl_show));

updatePlotPredictionAnalysis(mainFigure, 'predictionTable')

%% callback assignments

set(get(h_radio(1), 'parent'), 'SelectionChangedFcn', {@predictionRadio, mainFigure, h_radio});
set(h_button, 'ButtonPushedFcn', {@predictionButton, mainFigure});
set(findobj(h_edit, 'type', 'uieditfield'), 'ValueChangedFcn', {@predictionEdit, mainFigure, h_edit});
set(h_table(end), 'CellEditCallback', {@predictionTableEdit, mainFigure});
set(h_table(end), 'CellSelectionCallback', {@predictionTableSelect, ...
    mainFigure}); % might want to change to key press

end

function predictionRadio(src, event, mainFigure, h_radio)

obj = get(mainFigure, 'UserData');
str = h_radio([h_radio.Value]).Text;
obj = changeObject(obj, 'prediction', 'type', str);
set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure);

end

function predictionButton(src, event, mainFigure)

obj = get(mainFigure, 'UserData');
generatePredictionFigure(obj);

end

function predictionEdit(src, event, mainFigure, h_edit)

newLims = editExtract(h_edit);

obj = get(mainFigure, 'UserData');
if isnan(newLims(1))
    newLims(1) = obj.externalUserData.min_I_show;
elseif newLims(1) < 1e-6
    newLims(1) = 1e-6;
elseif newLims(1) > 1
    newLims(1) = 1;
end
if isnan(newLims(2))
    newLims(2) = obj.externalUserData.max_hkl_show;
elseif newLims(2) < 1
    newLims(2) = 1;
end

obj.externalUserData.min_I_show = newLims(1);
obj.externalUserData.max_hkl_show = newLims(2);
set(h_edit(2), 'Value', num2str(obj.externalUserData.min_I_show));
set(h_edit(4), 'Value', num2str(obj.externalUserData.max_hkl_show));

if obj.externalUserData.max_hkl_show > obj.prediction.max_hkl
    obj = changeObject(obj, 'prediction', 'max_hkl', ...
        floor(obj.externalUserData.max_hkl_show));
    set(mainFigure, 'UserData', obj);
    updatePlotPredictionAnalysis(mainFigure);
else
    minI = obj.externalUserData.min_I_show;
    maxhkl = obj.externalUserData.max_hkl_show;
    I = obj.prediction.I;
    hkl = obj.prediction.hkl;
    displayInd = I >= minI & all(abs(hkl) <= maxhkl, 2);
    obj.externalUserData.displayInd = displayInd;
    set(mainFigure, 'UserData', obj);
    updatePlotPredictionAnalysis(mainFigure, 'predictionDisplay');
end

end

function predictionTableEdit(src, event, mainFigure)

tableData = get(src, 'Data');

if size(tableData, 1) > 1
    tableCheckedInd = cell2mat(tableData(:,6));
    rewriteTable = false;
    if event.Indices(1) == 1 % if All was clicked
        tableCheckedInd(:) = tableCheckedInd(1);
        rewriteTable = true;
    else
        if all(tableCheckedInd(2:end)) && ~tableCheckedInd(1)
            tableCheckedInd(1) = true;
            rewriteTable = true;
        elseif tableCheckedInd(1) && ~event.NewData
            tableCheckedInd(1) = false;
            rewriteTable = true;
        end
    end
    
    obj = get(mainFigure, 'UserData');
    checkedInd = obj.externalUserData.checkedInd;
    displayInd = obj.externalUserData.displayInd;
    checkedInd([true; displayInd]) = tableCheckedInd;
    
    obj.externalUserData.checkedInd = checkedInd;
    set(mainFigure, 'UserData', obj);
    
    if rewriteTable
        updatePlotPredictionAnalysis(mainFigure, 'predictionDisplay');
    else
        updatePlotPredictionAnalysis(mainFigure, 'predictionPlot');
    end
    
end

end

function predictionTableSelect(src, event, mainFigure)

indx = event.Indices;
indx(indx(:,1) == 1,:) = []; % not allowing an all highlight
indx(indx(:,2) == 6,:) = []; % not allowing plot? highlight

obj = get(mainFigure, 'UserData');

if isempty(indx)
    obj.externalUserData.clickedInd = false(size(...
        obj.externalUserData.displayInd));
else
    indx = indx(:,1) - 1;
    tableClickedInd = false(size(get(src, 'Data'), 1) - 1, 1);
    tableClickedInd(indx) = true;
    displayInd = obj.externalUserData.displayInd;
    clickedInd = obj.externalUserData.clickedInd;
    clickedInd(displayInd) = tableClickedInd;
    obj.externalUserData.clickedInd = clickedInd;
end

set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure, 'predictionPlot');

end