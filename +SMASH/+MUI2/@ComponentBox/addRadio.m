% addRadio Add radio button block
%
% This method adds a radio button block to the current row.
%    h=addRadio(object,width,number,type, box);
% Optional input "width" defines the number of horizontal characters that
% must fit inside each button; the default value is 10. Optional input 
% "number" indicates the number of stacked buttons to be created with the 
% current gap settings. Optional input "type" specifies 'vertical' or 
% 'horizontal' stacking; if 'horizontal', the user can input a vector for
% the width to individually size each radio. Optional input box specifies 
% 'on' or 'off' for the box surrounding the radio buttons. Output "h" is a 
% handle array of uiradiobutton components.
%
% NOTE: only the button group object created to hold the requested radio
% buttons are stored in the CurrentRow and Component property.
%
% See also ComponentBox, setGap
%
function h=addRadio(object,width,number,type, box)

assert(isscalar(object),...
    'ERROR: components can only be added to one box at a time');

% manage input
Narg=nargin();
if (Narg < 2) || isempty(width)
    width=10;
else
    assert(isnumeric(width) && all(width > 0),...
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

if Narg < 4
    type = 'vertical';
end

if isscalar(width)
    if strcmpi(type(1),'h')
        width = repmat(width, 1, number);
    end
else
    if ~strcmpi(type(1),'h')
        width = max(width);
    else
        assert(numel(width) == number, ...
            'ERROR: width-number mismatch');
    end
end

if Narg < 5
    box = 'on';
end

% size calculations
hoffset=checkCurrentRow(object);

width=object.Calibration.textWidthFcn(width);
width=width+object.Calibration.boxSizeFcn(1);
height=object.Calibration.textHeightFcn(1);

% create uiradio component(s)
parent=uibuttongroup(object.Figure);
for n=1:number
    new=uiradiobutton(parent);    
    applyFont(object,new);
    if n == 1
        h=repmat(new,[1 number]);
    else
        h(n)=new; %#ok<AGROW>
    end
    if strcmpi(type(1), 'h')
        h(n).Position(1) = sum(width(1:n-1)) + n*object.Gap.Horizontal;
        h(n).Position(2)=object.Gap.Vertical;
        h(n).Position(3)=width(n);
    else
        h(n).Position(1)=object.Gap.Horizontal;
        h(n).Position(2)=(n-1)*height+n*object.Gap.Vertical;
        h(n).Position(3)=width;
    end
    h(n).Position(4)=height;
end
% h=h(end:-1:1); N.B. made decision to reverse this D.D. line to enable better compatibility with existing code
defineControlData(object,parent);
setappdata(parent,'hoffset',hoffset);
if strcmpi(type(1), 'h')
    setappdata(parent,'voffset',height+object.Gap.Vertical);
    parent.Position(3)=sum(width)+(number+1)*object.Gap.Horizontal;
    parent.Position(4)=height+2*object.Gap.Vertical;
else
    setappdata(parent,'voffset',number*height+(number+1)*object.Gap.Vertical);
    parent.Position(3)=width+2*object.Gap.Horizontal;
    parent.Position(4)=number*height+(number+1)*object.Gap.Vertical;
end

% handle box
if strcmpi(box, 'off')
    set(parent, 'bordertype', 'none');
    for ii = 1:numel(h)
        h(ii).Position(1) = h(ii).Position(1) - object.Gap.Horizontal+1;
    end
    parent.Position(3) = parent.Position(3) - 2*object.Gap.Horizontal+1;
    parent.Position(4) = parent.Position(4) - object.Gap.Vertical+1;
end

object.CurrentRow=[object.CurrentRow parent];
object.Component=[object.Component parent];
refresh(object);

end