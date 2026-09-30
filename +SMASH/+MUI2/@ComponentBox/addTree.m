% addTree Add tree block
%
% This method adds a tree block to the current row.
%    h=addTree(object,width,rows);
% Optional input "width" defines the number of horizontal characters that
% must fit inside the tree, using default value of 10.   Optional input
% "rows" defines the vertical size of the tree, with a default value of 4
% Output "h" a two-component handle array for the uilabel and uitree
% components. The former is placed to the left or above the latter based on
% the LabelPosition property.
%
% The default style 'tree' is used for the created uitree.  This
% behavior can be changed with an additonal input:
%    h=addTree(object,width,rows,style);
% where "style" can be 'push' or 'state'.
% 
% Scalar widths are automatically shared between components.  A two-element
% array [width1 width2] can be used to individually size the label and
% tree components.  The second approach is particularly useful when the
% label is placed to the left of the tree.  Distinct component sizing
% is supported but usually unneccessary for labels above the tree.
%
% See also ComponentBox, setLabelPosition, uilabel, uitree
%
function h=addTree(object,width,rows,style)

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

if (Narg < 3) || isempty(rows)
    rows=3;
else
    assert(isnumeric(rows) && isscalar(rows) && (rows > 0),...
        'ERROR: invalid number of rows');
    rows=ceil(rows);
end

if (Narg < 4) || isempty(style) || strcmpi(style,'tree')
    style='tree';
elseif strcmpi(style,'checkbox')
    style='checkbox';
else
    error('ERROR: style must be ''tree'' or ''checkbox''');
end

% size calculations
hoffset=checkCurrentRow(object);

width=object.Calibration.textWidthFcn(width);
width(2)=width(2)+object.Calibration.boxSizeFcn(1); % make room for scroll bar
height=object.Calibration.textHeightFcn([1 rows]);

% create uilabel and uidropdown components
h(1)=uilabel(object.Figure);
h(2)=uitree(object.Figure,style);
for n=1:2
    h(n).Position(3)=width(n);
    h(n).Position(4)=height(n);
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