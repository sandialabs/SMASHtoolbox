% addCheckbox Add check box block
%
% This method adds a check box block to the current row.
%    h=addCheckbox(object,width,number);
% Optional input "width" defines the number of horizontal characters that
% must fit inside each check box; the default value is 10.  Optional input
% "number" indicates the number of vertically-stacked check boxes to be
% created with the current gap setting.  Output "h" is a handle array of
% uicheckbox components.
%
% See also ComponentBox, setGap, uicheckbox
%
function h=addCheckbox(object,width,number)

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

if (Narg < 3) || isempty(number)
    number=1;
else
    assert(isnumeric(number) && isscalar(number) && (number > 0),...
        'ERROR: invalid number of check boxes');
    number=ceil(number);
end

% size calculations
hoffset=checkCurrentRow(object);

width=object.Calibration.textWidthFcn(width);
width=width+object.Calibration.boxSizeFcn(1);
height=object.Calibration.textHeightFcn(1);

% create uibutton component(s)
for n=1:number
    new=uicheckbox(object.Figure);
    defineControlData(object,new);
    applyFont(object,new);
    if n == 1
        h=repmat(new,[1 number]);
    else
        h(n)=new; %#ok<AGROW>
    end
    h(n).Position(3)=width;
    h(n).Position(4)=height;
    setappdata(h(n),'header',false);
    setappdata(h(n),'hoffset',hoffset);
    setappdata(h(n),'voffset',n*height+(n-1)*object.Gap.Vertical);
end

object.CurrentRow=[object.CurrentRow h];
object.Component=[object.Component h];
refresh(object);

end