% addMessage Add message block
%
% This method adds a message block to the current row.
%    h=addMessage(object,width,rows);
% Optional input "width" defines the number of horizontal characters that
% must fit inside the block; the default value is 20.  Optional input
% "rows" indicates the number of vertical characters inside the block, with
% a default value of 1.  Output "h" is the handle for a uilabel component.
%
% See also ComponentBox, uilabel
%
function h=addMessage(object,width,rows)

assert(isscalar(object),...
    'ERROR: components can only be added to one box at a time');

% manage input
Narg=nargin();
if (Narg < 2) || isempty(width)
    width=20;
else
    assert(isnumeric(width) && isscalar(width) && (width > 0),...
        'ERROR: invalid width');
    width=ceil(width);
end

if (Narg < 3) || isempty(rows)
    rows=1;
else
    assert(isnumeric(rows) && isscalar(rows) && (rows > 0),...
        'ERROR: invalid number of rows');
    rows=ceil(rows);
end

% size calculations
hoffset=checkCurrentRow(object);

width=object.Calibration.textWidthFcn(width);
height=object.Calibration.textHeightFcn(rows);

% create uilabel component
h=uilabel(object.Figure);
h.Position(3)=width;
h.Position(4)=height;
applyFont(object,h);
defineControlData(object,h);
setappdata(h,'hoffset',hoffset);
setappdata(h,'voffset',height);

object.CurrentRow=[object.CurrentRow h];
object.Component=[object.Component h];
refresh(object);

end