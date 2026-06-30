% set Set display resolution
%
% This method manually sets the display resolution..
%    set(object,value);
% The input "value" indicates the screen pixels per inch for the current
% display.  The default value is system-dependent, e.g. 96 for Windows and
% 72 for Macs.  Only new graphics are affect by resolutions changes;
% existing graphics remain unaltered.
%
% NOTE: this DPI setting persists across MATLAB settings.  It may need to
% be updated whenever displays are added or removed from the system.
%
% See also LocalDisplay, measure, set
%
function set(~,value)

group='LocalDisplay';
name='LastSet';

if ~ispref(group,name)
    default=get(groot(),'ScreenPixelsPerInch');
    setpref(group,name,default);
end
current=getpref(group,name);

% manage input
if (nargin < 2) || isempty(value)
    value=current;
else
    assert(isnumeric(value) && isscalar(value) && (value > 0),...
        'ERROR: invalid DPI setting');    
end

setpref(group,name,value);

% manage output
fprintf('Screen resolution set to %g DPI\n',value);

end