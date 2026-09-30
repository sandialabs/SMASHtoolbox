% addTable Add table box block
%
% This method adds a list box block to the current row.
%    h=addTable(object,width,rows);
% Optional input "width" defines the number of horizontal characters that
% must fit inside each table column; the default value is [10 10].
% Optional input "rows" defines the vertical size of the table, with a
% default value of 4.  Output "h" is a handle graphic array for N uilabels
% (where N is the number of defined widths) plus one uitable. 
%
% See also ComponentBox, setLabelPosition, uilabel, uitable
%
function h=addTable(object,width,rows)

assert(isscalar(object),...
    'ERROR: components can only be added to one box at a time');

% manage input
Narg=nargin();
if (Narg < 2) || isempty(width)
    width=[10 10];
else
    assert(isnumeric(width) && all(width > 0),'ERROR: invalid width');
    width=ceil(width);
end

if (Narg < 3) || isempty(rows)
    rows=4;
else
    assert(isnumeric(rows) && isscalar(rows) && (rows > 0),...
        'ERROR: invalid number of rows');
    rows=ceil(rows);
end

% size calculations
hoffset=checkCurrentRow(object);

width=object.Calibration.textWidthFcn(width);
height=object.Calibration.textHeightFcn([1 rows]);

% create uilabel and uitable components
columns=numel(width);
for n=1:columns
    new=uilabel(object.Figure);
    new.VerticalAlignment='bottom';
    new.Position(3)=width(n);
    new.Position(4)=height(1);
    defineControlData(object,new);
    setappdata(new,'header',true);
    setappdata(new,'hoffset',hoffset+sum(width(1:n-1)));
    setappdata(new,'voffset',height(1));
    if n == 1
        h=repmat(new,[1 columns+1]);
    else
        h(n)=new;
    end
end

h(end)=uitable(object.Figure,'ColumnName',{},'RowName',{},...
    'ColumnWidth',num2cell(width));
h(end).Position(3)=sum(width)+object.Calibration.boxSizeFcn(1);
h(end).Position(4)=height(2);
defineControlData(object,h(end));
setappdata(h(end),'hoffset',hoffset);
setappdata(h(end),'voffset',h(end).Position(4));
set(h(end),'Data',cell(rows,columns));
applyFont(object,h);

object.CurrentRow=[object.CurrentRow h];
object.Component=[object.Component h];
refresh(object);

end