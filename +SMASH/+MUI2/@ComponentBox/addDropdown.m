% addDropdown Add drop down block
%
% This method adds a drop down block to the current row.
%    h=addDropdown(object,width);
% Optional input "width" defines the number of horizontal characters that
% must fit inside the drop down, using default value of 10.  Output "h" a
% two-component handle array for the uilabel and uidropdown components.
% The former is placed to the left or above the latter based on the
% LabelPosition property. 
% 
% Scalar widths are automatically shared between components.  A two-element
% array [width1 width2] can be used to individually size the label and
% dropdown components.  The second approach is particularly useful when the
% label is placed to the left of the drop down.  Distinct component sizing
% is supported but usually unneccessary for labels above the drop down.
%
% See also ComponentBox, setLabelPosition, uilabel, uidropdown
%
function h=addDropdown(object,width)

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
width(2)=width(2)+object.Calibration.boxSizeFcn(1);
height=object.Calibration.textHeightFcn(1);

% create uilabel and uidropdown components
h(1)=uilabel(object.Figure);
h(2)=uidropdown(object.Figure);
for n=1:2
    h(n).Position(3)=width(n);
    h(n).Position(4)=height;
end
applyFont(object,h);
defineControlData(object,h);

setappdata(h(1),'hoffset',hoffset);
setappdata(h(1),'voffset',h(1).Position(4));
if strcmpi(object.LabelPosition,'above')
    setappdata(h(1),'header',true);    
    setappdata(h(2),'hoffset',hoffset);    
    set(h(1),'VerticalAlignment','bottom');
else
    setappdata(h(2),'hoffset',hoffset+h(1).Position(3));
    set(h(1),'HorizontalAlignment','right');    
end
setappdata(h(2),'header',false);
setappdata(h(2),'voffset',h(2).Position(4))

object.CurrentRow=[object.CurrentRow h];
object.Component=[object.Component h];
refresh(object);

end