% pushLabel Add entries to the label queue
%
% This method adds new text entries to the label queue.
%    pushLabel(object,arg1,arg2,...);
% Each input argument can be a character array, a cell array of strings, or
% a string array.  Labels are collected into a unified string array and
% effective width in the LabelQueue property.
%
% Effective width requirements are based on font settings when labels are
% pushed onto the queue.  Width is automatically updated when labels are
% added and never decreases as long as existing labels are present.  This
% value is only reset when labels are pushed onto an empty queue.
%
% One extra character is added to width calculations by default.  This
% behavior can be modified by passing a numeric argument before any labels.
%    pushLabel(object,padding,arg1,arg2,...);
% Input "padding" must be a number >= 0.  Integer values correspond to
% multiples of the "W" character; there is no requirement that "padding"
% be an integer.
%
% Although this method is designed to be used with the popLabel method,
% labels can be pushed into queue purely for width analysis.  Complex
% graphical interfaces may be better suited to push/flush/push operations
% and manual component addition.
%
% See also ComponentBox, flushLabel, popLabel
%
function pushLabel(object,varargin)

% manage input
assert(nargin > 1,'ERROR: no label(s) specified');
if isnumeric(varargin{1})
    padding=varargin{1};
    varargin=varargin(2:end);
    assert(isscalar(padding) && (padding >= 0),...
        'ERROR: invalid character padding');
else
    padding=1;
end

Narg=numel(varargin);
k=1;
content=cell(k);
for m=1:Narg
    arg=varargin{m};
    if ischar(arg)
        arg={arg};
    end
    assert(iscellstr(arg) || isstring(arg),'ERROR: invalid label');
    for n=1:numel(arg)
        content{k}=arg{n};
        k=k+1;
    end
end
content=string(content);

cal=calfont.lookup(object.Font.Name,object.Font.Size);
width=cal.WidthFcn(content,padding);

% update queue
data=object.LabelQueue;
if isempty(data.Content)
    data.Width=width;
    data.Content=content;
else
    data.Width=max(width,data.Width);
    data.Content=[data.Content content];
end

object.LabelQueue=data;

end