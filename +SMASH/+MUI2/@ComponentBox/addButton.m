% addButton Add button block
%
% This method adds a button block to the current row.
%    h=addButton(object,width,number);
% Optional input "width" defines the number of horizontal characters that
% must fit inside each button; the default value is 10.  Optional input
% "number" indicates the number of vertically-stacked buttons to be created
% with the current gap settings.  Output "h" is a handle array of uibutton
% components.
%
% The default style 'push' is used for the created uibuttons.  This
% behavior can be changed with an additional input:
%    h=addButton(object,width,number,style);
% where "style" can be 'push' or 'state'.
%
% See also ComponentBox, setGap
%
function h=addButton(object,width,number,style)

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

if (Narg < 4) || isempty(style) || strcmpi(style,'push')
    style='push';
elseif strcmpi(style,'state')
    style='state';
else
    error('ERROR: button style must be ''push'' or ''state''');
end

% size calculations
hoffset=checkCurrentRow(object);

width=object.Calibration.textWidthFcn(width);
height=object.Calibration.textHeightFcn(1);

% create uibutton component(s)
for n=1:number
    new=uibutton(object.Figure,style);
    defineControlData(object,new)
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