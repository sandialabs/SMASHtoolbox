% scroll Scroll to box location
%
% This method scrolls the component box to a specified location.
%    scroll(object,vlocation); % 'top' or 'button'
%    scroll(object,hlocation); % 'left' or 'right'
%    scroll(object,hlocation,vlocation); % combinations of the above
% Scrolling can also be specified in terms of a specific component:
%    scroll(object,comp);
% or pixel location.
%    scroll(object,x,y);
%    scroll(object,[x y]);
% Each of the above commands enables scrolling in the component box.  That
% feature can be enabled/disabled:
%    scroll(object,mode); % 'on' or 'off'
% and queried at at any time.
%    mode=scroll(object);
%
% See also ComponentBox
% 
function varargout=scroll(object,varargin)

assert(isscalar(object),...
    'ERROR: scroll operations must be done one object at a time');

% manage input
Narg=nargin();
mode=object.Figure.Scrollable;
% state query
if Narg == 1
    varargout{1}=mode;
    return
end

% state changes
state={'on' 'off'};
if (Narg == 2) && any(strcmpi(varargin{1},state))
    object.Figure.Scrollable=lower(varargin{1});
    return
end

% other operations
object.Figure.Scrollable='on';
try
    scroll(object.Figure,varargin{1});
catch ME
    object.Figure.Scrollable=mode;
    throwAsCaller(ME);
end

end