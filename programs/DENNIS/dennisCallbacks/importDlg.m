function importDlg(src, event)

warning('off', 'all');
mainFigure = ancestor(src, 'figure', 'toplevel');
things2close = getappdata(mainFigure);
names = fieldnames(things2close);
for ii = length(names):-1:6 % only deletes dialogs
    delete(things2close.(names{ii}));
end
warning('on', 'all')

[file, path] = uigetfile('*.mat', 'Pick File');
if ~isnumeric(file)
    try
        filepath = fullfile(path, file);
        load(filepath, 'obj');
        obj = convertFromOld(obj);
        set(mainFigure, 'UserData', obj);
        if isfield(obj.externalUserData, 'viewVals')
            view(get(mainFigure,'CurrentAxes'), ...
                obj.externalUserData.viewVals(1), ...
                obj.externalUserData.viewVals(2));
        end
        updatePlotPredictionAnalysis(mainFigure);
    catch
        errordlg('Import Failed')
    end
end

end