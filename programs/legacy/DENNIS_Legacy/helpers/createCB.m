function [cb, mainFigure, ex] = createCB(src, name, varargin)

% parse input

createFlag = true;
if ~isempty(varargin)
    createFlag = varargin{1};
end

% check if cb already exists and make it if it doesn't

ex = false;
mainFigure = ancestor(src, 'figure', 'toplevel');
cb = getappdata(mainFigure, name);
if ~isempty(cb) && isvalid(cb)
    if ishandle(cb) % combined
        figure(cb);
        ex = true;
    elseif isprop(cb, 'Figure') && ishandle(cb.Figure) % cb
        show(cb);
        ex = true;
    end
end 
if createFlag && ~ex
    cb = SMASH.MUI2.ComponentBox('hide');
    setName(cb, name); % added this for cb that is later combined
    setappdata(mainFigure, name, cb);
end
end