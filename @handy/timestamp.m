% timestamp Generate time stamp
%
% This *static* method generates current time stamps.
%    [value,object]=handy.timestamp();
% Output "value" is character representation of the output "object",
% which is based on the datetime class. The compact stamp displays the
% current date (yyyy-MM-dd) and time of day (hh:mm:ss) separated by the
% a space character
%
% Time stamps are generated immediately by default.  This behavior can be
% controlled with an input argument.
%    [...]=handy.timestamp('quick'); % default
%    [...]=handy.timestamp('unique'); % default
% Unique mode ensures that the new time stamp is different from the most
% recently created value, pausing up to one second as needed.
%
% See also handy, datetime
%
function [value,object]=timestamp(mode)

Narg=nargin();
if (Narg < 1) || isempty(mode) || strcmpi(mode,'quick')
    quick=true();
elseif strcmpi(mode,'unique')
    quick=false();
else
    error('ERROR: invalid time stamp mode');
end

format='';
persistent previous
while true
    object=datetime('now');
    if isempty(format)
        format=object.Format;
    end
    %object.Format='yyyMMdd''T''HHmmss';
    object.Format='yyyy-MM-dd hh:mm:ss';
    value=string(object);
    if isempty(previous) || quick
        break
    elseif ~isequal(value,previous)
        break
    end
    pause(0.1);
end
previous=value;
object.Format=format;

end