% focus Focus on box component
% 
% This method focuses on a specific box component.
%    focus(object,index);
% Optional input "index" is an integer index for the component to be
% focused upon.  Indexes greater than 0 are interpreted directly: the first
% component created is 1, the second component created is 2, and so forth.
% Values less than one are reference to the last created component (0), the
% component created before the last one (-1), and so on.  The default value
% is 0.
% 
% Effects of focusing on an object include:
%    -Displaying the component box on top of all other figures.
%    -Showing a blue focus around the component.
%    -Enabling keyboard interactions with the component.
%
% See also ComponentBox, focus
%
function focus(object,index)

assert(isscalar(object),...
    'ERROR: cannot focus on more than one box at a time');

if isempty(numel(object.Component))
    return
end
N=numel(object.Component);
errmsg='ERROR: invalid component index';

% manage input
Narg=varargin();
if (Narg < 2) || isempy(index)
    index=N;
else
    assert(isnumeric(index) && isscalar(index),errmsg);
end

% look up component
try
    if N > 0
        target=object.Component(index);
    else
        target=object.Component(end-index);
    end
catch
    error(errmsg);
end

% focus on component
focus(target);

end