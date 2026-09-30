% addSlider Add slider block
%
% This method adds a horizontal slider block to the current row.
%    h=addSlider(object,width);
% Optional input "width" defines the number of horizontal characters that
% must fit inside the slider, using default value of 10.  Output "h" a
% two-component handle array for the uilabel and uislider components.
% The former is placed to the left the latter based.
%
% Scalar widths are automatically shared between components.  A two-element
% array [width1 width2]  can be used to individually size the label and
% slider components.  Note that the label is always placed to the left of a
% slider, regardless of the current LabelPosition value. Setting width1 to
% 0 hides the label and eliminates its impact on sizing.
%
% An additional argument:
%    h=addSlider(object,width,style);
% can be specified to control slider style.  The default value 'slider'
% supports a single thumb value, while the value 'range' creates two thumb
% values.
%
% See also ComponentBox, uilabel, uislider
%
function h=addSlider(object,width,style)

assert(isscalar(object),...
    'ERROR: components can only be added to one box at a time');

% manage input
Narg=nargin();
if (Narg < 2) || isempty(width)
    width=10;
else
    assert(isnumeric(width) && all(width >= 0),'ERROR: invalid width');
    width=ceil(width);
end

if isscalar(width)
    width=repmat(max(width),[1 2]);
else
    width=width(1:2);
    assert(width(2) > 0, 'ERROR: invalid width');
end

if (Narg < 3) || isempty(style) || strcmpi(style,'slider')
    style='slider';
elseif strcmpi(style,'range')
    style='range';
else
    error('ERROR: style must be ''slider'' or ''range''');
end

% size calculations
hoffset=checkCurrentRow(object);
bs=object.Calibration.boxSizeFcn(1);
height=object.Calibration.textHeightFcn(1);
if width(1) > 0
    width=object.Calibration.textWidthFcn(width);
else % user doesn't want a label
    width(2) = object.Calibration.textWidthFcn(width(2));
    bs = object.Margin.Horizontal/2; % approximate addition to margin, may need tuning
end

% create uilabel and uidropdown components
h(1)=uilabel(object.Figure);
h(2)=uislider(object.Figure,style);
applyFont(object,h);
for n=1:2
    h(n).Position(3)=width(n);
end
h(1).Position(4)=max(height,h(2).OuterPosition(4));

defineControlData(object,h);
setappdata(h(1),'hoffset',hoffset);
setappdata(h(1),'voffset',h(1).Position(4));
setappdata(h(2),'hoffset',hoffset+h(1).Position(3)+bs);
set(h(1),'HorizontalAlignment','right');
shift=h(2).Position(2)-h(2).OuterPosition(2);
setappdata(h(2),'voffset',h(2).OuterPosition(4)-shift);
if width(1) == 0 % user doesn't want a label
    set(h(1), 'Visible', 'off');
end

object.CurrentRow=[object.CurrentRow h];
object.Component=[object.Component h];
refresh(object);

end