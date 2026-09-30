% store Save font calibration for future use
%
% This *static* method saves current font calibrations for use in future
% MATLAB sessions.
%    calfont.store(name);
% Optional input "name" associates a specific name with calibration for
% later reference.  The default value 'LastCalibration' is reserved and
% always used in addition to specified name.  In other words, one copy of
% the calibration is saved when no name is specified and two copies are
% saved when a name is specified.  Stored calibrations persist between
% MATLAB sessions.
%
% NOTE: previous calibrations are automatically overwritten without warning.
%
% See also calfont, restore
%
function store(name)

DefaultName='LastCalibration';
if nargin() < 1
    name='';
else
    assert(isvarname(name),'ERROR: invalid calibration name');  
    assert(~strcmp(name,DefaultName),...
        'ERROR: calibration name "%s" is reserved',DefaultName);
end

previous=getappdata(groot(),'calfont');
setpref('calfont',DefaultName,previous);
if ~isempty(name)
    setpref('calfont',name,previous);
end

end