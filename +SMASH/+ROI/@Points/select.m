% select Interactive point selection
%
% This method provides interactive selection of points using the mouse.
%    object=select(object); % use current axes
%    object=select(object,target); % use target axes
%
% See also Points, define, view
%

%
% created September 24, 2017 by Daniel Dolan (Sandia National Laboratories)
% significantly revised October 27 by Daniel Dolan
%    -Selection begins and ends with dialog box
%    -Points can now be deleted from the dialog box
%    -Valid coordinate changes are applied immediately
%
function object=select(object,target)

%% manage input
assert(isscalar(object),...
    'ERROR: interactive selection must be done one region at a time');

if (nargin < 2) || isempty(target)
    target=gca;
elseif ishandle(target)
    if strcmpi(get(target,'Type'),'figure')
        target=get(target,'CurrentAxes');
    else
        target=ancestor(target,'axes');
    end
else
    error('ERROR: invalid target axes');
end

%% launch appropriate GUI
switch lower(SMASH.Graphics.checkGraphics())
    case 'java'
        object=selectLegacy(object,target);
    case 'javascript'
        object=selectCurrent(object,target);
end

end