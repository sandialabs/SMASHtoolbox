function exportDlg(src, event)

mainFigure = ancestor(src, 'figure', 'toplevel');
obj = get(mainFigure, 'UserData');
[v1, v2] = view(get(mainFigure, 'CurrentAxes'));
obj.externalUserData.viewVals = [v1, v2];
obj.externalUserData = rmfield(obj.externalUserData,'version');

[file, path] = uiputfile('*.mat', 'Save File');
if ~isnumeric(file)
    filepath = fullfile(path, file);
    save(filepath, 'obj');
end

end