function updateFromEdit(mainFigure, newVals, category, subcategory, ...
    h_edit, updateEverything, varargin)

% update object

obj = get(mainFigure, 'UserData');
obj = changeObject(obj, category, subcategory, newVals, varargin{:});
set(mainFigure, 'UserData', obj);

% update edit boxes

h_edit = findobj(h_edit, 'Type', 'uieditfield');
for ii = 1:length(newVals)
    set(h_edit(ii), 'Value', ...
        num2str(obj.(category).(subcategory)(ii)));
end

% update plot and results

if updateEverything
    updatePlotPredictionAnalysis(mainFigure);
else
    updatePlotPredictionAnalysis(mainFigure, category);
end

end