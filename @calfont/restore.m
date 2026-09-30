% restore Load previous font calibration
%
% This *static* method loads a previous font calibration.
%    calfont.restore(name);
% Optional input "name" defaults to 'LastCalibration'.  Any previously
% defined calibration name can be requested.
%
% 
% The command:
%    calfont.restore('-list');
% lists the name of all existing calibration in the command window.
% Requesting an output:
%    name=calfont.restore('-list');
% returns the same information as cellstr array.
%
% NOTE: restoring a previous calibration overwrites all current
% calibrations.
%    
% See also calfont, store
%
function varargout=restore(name)

assert(ispref('calfont'),'ERROR: no stored font calibrations');
previous=getpref('calfont');

if (nargin() < 1) || isempty(name)
    name='LastCalibration';
elseif strcmpi(name,'-list')
    name=fieldnames(previous);
    if nargout() > 0
        varargout{1}=name;
        return
    end
    fprintf('Existing font calibrations:\n');
    fprintf('   %s\n',name{:});
    return
elseif ~isvarname(name)
    error('Invalid calibration name');
end

try
    previous=previous.(name);
catch
    error('Requested calibration not found');
end

current=calfont.get();
if isequal(previous.MonitorPositions,current.MonitorPositions) || ...
        isequal(previous.ScreenSize,current.ScreenSize)    
    setappdata(groot(),'calfont',previous);
else
    error('Stored calibration involves different screen settings');
end

end