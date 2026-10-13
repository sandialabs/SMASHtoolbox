% copy Copy component
%
% This method copies components from the current box to another graphic.
%    [parent,new]=copy(object,target);
% The input "target" can specify an existing figure, tab, or panel; a new
% figure is created when this input is omitted/empty. The output "parent"
% is an intermediate uipanel within the target graphic containing the
% copied components.  Graphic handles for those copies are returned in
% output "new".
%
% Target graphic sizes are usually adjusted to fit components.  The
% behavior can be controlled:
%    [parent,new]=copy(object,target,mode);
% with optional input "mode" (default is 'fit').  Setting the mode to
% 'scroll' makes the target graphic scrollable, while the mode 'ignore'
% leaves the target size unchanged.
%
% NOTE: components should be finalized *after* being copied, not before.
% While most original component settings transfer to the copied objects,
% callback references to the former may not function correctly.
%
% See also ComponentBox, combine, fit
%
function [parent,new]=copy(object,target,mode)

assert(isscalar(object),...
    'ERROR: component box objects must be copied one element at a time');

assert(~isempty(object.Component),'ERROR: cannot copy empty box');

% manage input
Narg=nargin();
if (Narg < 2) || isempty(target)
    target=uifigure('AutoResizeChildren','off');
else
    name=class(target);
    valid={'Figure' 'Tab' 'Panel'};
    assert(contains(name,valid,'IgnoreCase',true),...
        'ERROR: invalid copy target');
end

if (Narg < 3) || isempty(mode) || strcmpi(mode,'fit')
    mode='fit';
elseif strcmpi(mode,'scroll')
    mode='scroll';
elseif strcmpi(mode,'ignore')
    mode='ignore';
else
    error('ERROR: invalid copy mode');
end

% prepare to copy
actual=fit(object);

h=target;
fig=ancestor(target,'figure');
set([fig target],'AutoResizeChildren','off');
while h.Parent ~= fig
    try %#ok<TRYNC>
        set(h,'AutoResizeChildren','off');
    end
    h=h.Parent;
end

parent=uipanel(target,'AutoResizeChildren','off','Units','pixels',...
    'BorderType','none');
parent.Position(1:2)=0;
parent.Position(3:4)=actual;

% copy components to new parent
new=copyobj(object.Component,parent,'legacy');
switch mode
    case 'fit'
        h=target;
        if contains(class(h),'Tab')
            extra=h.Parent.OuterPosition-h.Parent.InnerPosition;            
            h.Parent.OuterPosition(3:4)=parent.Position(3:4)+extra(3:4);
        else
            h.Position(3:4)=parent.Position(3:4);
        end        
    case 'scroll'
        set(target,'Scrollable','on');
end

end