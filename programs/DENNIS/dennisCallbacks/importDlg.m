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
        if isfield(obj.externalUserData, 'viewVals')
            view(get(mainFigure,'CurrentAxes'), ...
                obj.externalUserData.viewVals(1), ...
                obj.externalUserData.viewVals(2));
        end
        obj.externalUserData.version = version('-release');
        set(mainFigure, 'UserData', obj);
        updatePlotPredictionAnalysis(mainFigure);
    catch ME
        msg = [ME.message(1:end-1), ' in ', ME.stack(1).name, ' at line ', ...
            num2str(ME.stack(1).line)];
        disp(msg);
        errordlg('Import Failed - See Command Window')
    end
end

end