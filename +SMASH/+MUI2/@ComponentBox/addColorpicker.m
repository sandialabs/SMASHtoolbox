% addColorpicker Add color picker block
% 
% This method adds an color picker block to the current row.
%    h=addColorpicker(object,width);
% Optional input "width" defines the number of horizontal characters that
% must fit inside the color picker box, using default value of 10.  Output
% "h" a two-component handle array for the uilabel and uicolorpicker
% components. The former is placed to the left or above the latter based on
% the LabelPosition property.
% 
% Scalar widths are automatically shared between components.  A two-element
% array [width1 width2] can be used to individually size the label and
% color picker components.  The second approach is particularly useful when
% the label is placed to the left of the color picker box.  Distinct
% component sizing is supported but usually unneccessary for labels above
% the color picker.
% 
% See also ComponentBox, setLabelPosition, uicolorpicker, uilabel
%
function h=addColorpicker(object,width)

assert(isscalar(object),...
    'ERROR: components can only be added to one box at a time');

% manage input
Narg=nargin();
if (Narg < 2) || isempty(width)
    width=10;
else
    assert(isnumeric(width) && all(width > 0),'ERROR: invalid width');
    width=ceil(width);
end

if isscalar(width) || strcmpi(object.LabelPosition,'top')
    width=repmat(max(width),[1 2]);
else
    width=width(1:2);
end

% size calculations
hoffset=checkCurrentRow(object);

width=object.Calibration.textWidthFcn(width);
height=object.Calibration.textHeightFcn(1);

% create uilabel and uieditfield components
h(1)=uilabel(object.Figure);
h(2)=uicolorpicker(object.Figure);
for n=1:2
    h(n).Position(3)=width(n);
    h(n).Position(4)=height;
end
applyFont(object,h);
defineControlData(object,h)

setappdata(h(1),'hoffset',hoffset);
setappdata(h(1),'voffset',h(1).Position(4));
if strcmpi(object.LabelPosition,'above')
    setappdata(h(1),'header',true);    
    setappdata(h(2),'hoffset',hoffset);    
    set(h(1),'VerticalAlignment','bottom');
else
    setappdata(h(1),'header',false);
    setappdata(h(2),'hoffset',hoffset+h(1).Position(3));
    set(h(1),'HorizontalAlignment','right');    
end
setappdata(h(2),'voffset',h(2).Position(4))

object.CurrentRow=[object.CurrentRow h];
object.Component=[object.Component h];
refresh(object);

end