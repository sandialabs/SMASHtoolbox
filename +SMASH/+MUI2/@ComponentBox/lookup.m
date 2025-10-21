% lookup Look up component index and handle
%
% This method looks up the index and handle for a requested box component.
%    [index,target]=lookup(object,arg);
% Optional input "arg" can be an array of integers or graphic handles; the
% default value is 0.  Numerical values greater than zero reference
% components in the order they were created, e.g. 3 indicates the third
% item added to the box.  Number less than or equal to zero references
% components with respect to last added item: 0 is the most recent
% component, -1 for the one before that, and so on.  The output "index" is
% an array of integers from 1 to N (for N box components), with the
% corresponding component handles returned in "target".
% 
% Graphic handles passed with "arg" are compared to the Components property
% for a reverse lookup.  In this case, the output "target" is identical to
% "arg" (assuming all elements are valid box components) and "index" is an
% integer array that maps the Components property to "arg".
%
% See as ComponentBox, overlay, remove
%
function [index,target]=lookup(object,arg)

valid=object.Component;
N=numel(valid);
assert(N > 0,'ERROR: no existing components');

% manage input
Narg=nargin();
if (Narg < 2) || isempty(arg)
    index=N;
    target=valid(N);
    return;
end

% forward mode
if isnumeric(arg)
    index=arg;
    k=(arg < 1);
    index(k)=N+index(k);
    try
        target=valid(index);
    catch
        error('ERROR: invalid component index');
    end
    return
end

% reverse mode
target=arg;
index=nan(size(target));
for n=1:numel(target)
    temp=find(target(n) == valid);
    assert(~isempty(temp),'ERROR: invalid component handle');  
    index(n)=temp;
end

end