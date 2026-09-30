% addImage Add image block
%
% This method adds an image block to the current row.
%    h=addImage(object,width,rows);
% Optional input "width" defines the number of horizontal characters that
% must fit inside the image; the default value is 20.  Optional input
% "rows" indicates the number of vertical characters inside the image, with
% a default value of 1.  Output "h" is the handle for a uiimage component.
%
% See also ComponentBox, uiimage
%
function h=addImage(object,width,rows)

assert(isscalar(object),...
    'ERROR: components can only be added to one box at a time');

% manage input
Narg=nargin();
if (Narg < 2) || isempty(width)
    width=10;
else
    assert(isnumeric(width) && isscalar(width) && (width > 0),...
        'ERROR: invalid width');
    width=ceil(width);
end

if (Narg < 3) || isempty(rows)
    rows=10;
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
h=uiimage(object.Figure);
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