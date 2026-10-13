% environment Determine computing environment
%
% This *static* method determines the computing environment.
%    [value,mathworks]=handy.environment();
% The output "value" can be 'Windows', 'Mac', 'Linux', 'Online', or
% 'Mobile'.  The output "mathworks" is logical true for MATLAB
% Online/Mobile environments and otherwise false.
% 
% Calls without an output request:
%    handy.environment();
% print information in the command window.
%
% Unlike MATLAB's builtin commands, such as computer, this function
% distinguishes MATLAB Online and MATLAB Mobile from standard Linux
% environments.  
%
% See also handy
%
function varargout=environment()

local=true();
if ispc()
    value='Windows';
elseif ismac()    
    value='Mac';
else
    value='Linux';
    list=getenv();
    pattern='MATLAB_ONLINE';
    match=false();
    name=keys(list);
    for n=1:numel(name)
        if strcmpi(name{n},pattern) || strcmpi(list(name{n}),pattern)
            match=true();
            break
        end
    end
    if match
        local=false();
        value='Online';
        try
            fig=uifigure('Visible','off');
            delete(fig);
        catch
            value='Mobile';
        end
    end
end

% manage output
if nargout() > 0
    varargout{1}=value;
    varargout{2}=~local;
elseif local
    fprintf('Computing environment is %s\n',value);
else
    fprintf('Computing environment is MATLAB %s\n',value);
end

end