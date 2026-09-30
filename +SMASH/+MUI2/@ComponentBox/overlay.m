% overlay Place new component on top of existing graphic
%
% This method places a new component on top of an existing graphic.
%    new=overlay(object,target,name);
% Mandatory input "target" indicates the reference component(s) by numeric
% index or graphical handle, following conventions of the lookup method.
%
% Mandatory input "name" indicates the new component type to be overlaid on
% the existing component(s).  Valid names include 'uibutton', 'uicheckbox',
% 'uicolorpicker', 'uidropdown', 'uieditfield', 'uihyperlink', 'uiimage',
% 'uilabel', 'uilistbox', 'uispinner', 'uitextarea', 'uitable', and
% 'uitree'.  Additional arguments:
%    new=overlay(object,target,name,option1,...);
% are passed to the respective object function.  For example, uibuttons
% accept a style parameter that controls whether the result is a push or
% state button.
%
% See also ComponentBox, lookup, remove
% 
function new=overlay(object,target,name,varargin)

assert(isscalar(object),...
    'ERROR: cannot overlay multiple component boxes');

% manage input
Narg=nargin();
assert(Narg >= 3,'ERROR: insufficent input');
try
    index=lookup(object,target);
catch ME
    throwAsCaller(ME);
end

assert(ischar(name) || isStringScalar(name),...
    'ERROR: invalid component request');
valid={'uibutton' 'uicheckbox' 'uicolorpicker' 'uidropdown' ...
    'uieditfield' 'uihyperlink' 'uiimage' 'uilabel' 'uilistbox' ...
    'uispinner' 'uitextarea' 'uitable' 'uitree'};
assert(any(strcmpi(name,valid)),...
    'ERROR: unsupported component request');

% determine overlap position
left=+inf;
bottom=+inf;
right=-inf;
top=-inf;
for k=index
    temp=object.Component(k);
    left=min(left,temp.Position(1));
    bottom=min(bottom,temp.Position(2));
    right=max(right,temp.Position(1)+temp.Position(3));
    top=max(top,temp.Position(2)+temp.Position(4));
end
pos=[left bottom right-left top-bottom];

% create new component
try
    new=feval(name,object.Figure,varargin{:});
catch ME
    throwAsCaller(ME);
end

applyFont(object,new);
new.Position=pos;

defineControlData(object,new);
setappdata(new,'row',NaN);
setappdata(new,'hoffset',pos(1)-object.Margin.Horizontal);
y=new.Position(2)-object.Margin.Vertical+object.Gap.Vertical;
setappdata(new,'voffset',y);

object.Component(end+1)=new;

end