% addToggle Add toggle button block
%
% This method adds a toggle button block to the current row.
%    h=addToggle(object,width,number);
% Optional input "width" defines the number of horizontal characters that
% must fit inside each button; the default value is 10.  Optional input
% "number" indicates the number of vertically-stacked buttons to be
% created with the current gap settings.  Output "h" is a handle array of
% uiradiobutton components.
%
% NOTE: only the button group object created to hold the requested toggle
% buttons are stored in the CurrentRow and Component property.
%
% See also ComponentBox, setGap
%
function h=addToggle(object,width,number)

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
        'ERROR: invalid number of buttons');
    number=ceil(number);
end

% size calculations
hoffset=checkCurrentRow(object);

width=object.Calibration.textWidthFcn(width);
height=object.Calibration.textHeightFcn(1);

% create uiradio component(s)
parent=uibuttongroup(object.Figure);
for n=1:number
    new=uitogglebutton(parent);    
    applyFont(object,new);
    if n == 1
        h=repmat(new,[1 number]);
    else
        h(n)=new; %#ok<AGROW>
    end
    h(n).Position(1)=object.Gap.Horizontal;
    h(n).Position(2)=(n-1)*height+n*object.Gap.Vertical;
    h(n).Position(3)=width;
    h(n).Position(4)=height;
end
h=h(end:-1:1);
defineControlData(object,parent);
setappdata(parent,'hoffset',hoffset);
setappdata(parent,'voffset',number*height+(number+1)*object.Gap.Vertical);
parent.Position(3)=width+2*object.Gap.Horizontal;
parent.Position(4)=number*height+(number+1)*object.Gap.Vertical;

object.CurrentRow=[object.CurrentRow parent];
object.Component=[object.Component parent];
refresh(object);

end