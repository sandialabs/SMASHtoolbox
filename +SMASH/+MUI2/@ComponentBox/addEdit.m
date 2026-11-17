% addEdit Add edit block
% 
% This method adds an edit block to the current row.
%    h=addEdit(object,width,style);
% Optional input "width" defines the number of horizontal characters that
% must fit inside the edit box, using default value of 10.  Output "h" a
% two-component handle array for the uilabel and uieditfield components.
% The former is placed to the left or above the latter based on the
% LabelPosition property. 
% 
% Scalar widths are automatically shared between components.  A two-element
% array [width1 width2] can be used to individually size the label and edit
% components.  The second approach is particularly useful when the label is
% placed to the left of the editable box. Setting width1 to 0 hides the 
% label and eliminates its impact on sizing.
%
% The default style 'text' is used for the created uieditfield.  This
% behavior can be changed with an additonal input:
%    h=addEdit(object,width,style);
% where "style" can be 'text' or 'numeric'.
% 
% See also ComponentBox, setLabelPosition, uieditfield, uilabel
%
function h=addEdit(object,width,style)

assert(isscalar(object),...
    'ERROR: components can only be added to one box at a time');

% manage input
Narg=nargin();
if (Narg < 2) || isempty(width)
    width=10;
else
    assert(isnumeric(width) && all(width >= 0),'ERROR: invalid width');
    width=ceil(width);
end

if isscalar(width) || strcmpi(object.LabelPosition,'top')
    width=repmat(max(width),[1 2]);
else
    width=width(1:2);
    assert(width(2) > 0, 'ERROR: invalid width')
end

if (Narg < 3) || isempty(style) || strcmpi(style,'text')
    style='text';
elseif strcmpi(style,'numeric')
    style='numeric';
else
    error('ERROR: invalid edit style');
end

% size calculations
hoffset=checkCurrentRow(object);
height=object.Calibration.textHeightFcn(1);
if width(1) > 0
    width=object.Calibration.textWidthFcn(width);
else % user doesn't want a label
    width(2) = object.Calibration.textWidthFcn(width(2));
end

% create uilabel and uieditfield components
h(1)=uilabel(object.Figure);
h(2)=uieditfield(object.Figure,style);
for n=1:2
    h(n).Position(3)=width(n);
    h(n).Position(4)=height;
end
applyFont(object,h);

defineControlData(object,h);
setappdata(h(1),'hoffset',hoffset);
setappdata(h(1),'voffset',h(1).Position(4));
if strcmpi(object.LabelPosition,'above') && width(1) > 0
    setappdata(h(1),'header',true);    
    setappdata(h(2),'hoffset',hoffset);    
    set(h(1),'VerticalAlignment','bottom');
else
    setappdata(h(1),'header',false);
    setappdata(h(2),'hoffset',hoffset+h(1).Position(3));
    set(h(1),'HorizontalAlignment','right');  
    if width(1) == 0 % user doesn't want a label
        set(h(1), 'Visible', 'off');
    end
end
setappdata(h(2),'voffset',h(2).Position(4))

object.CurrentRow=[object.CurrentRow h];
object.Component=[object.Component h];
refresh(object);

end