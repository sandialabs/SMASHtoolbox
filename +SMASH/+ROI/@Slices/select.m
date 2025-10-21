% select Interactive point selection
%
% This method provides interactive selection of points using the mouse.
%    object=select(object); % use current axes
%    object=select(object,target); % use target axes
%
% See also Slices, define, view
%

%
% created February 28, 2017 by Justin Brown (Sandia National Laboratories)
% - modification of Points.define and Curve.define
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