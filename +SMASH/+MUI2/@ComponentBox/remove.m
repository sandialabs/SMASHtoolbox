% remove Remove components from the box
%
% This method removes existing components from the box.
%    remove(object,target);
% Mandatory input "target" indicates the references component(s) by numeric
% index or graphical handle, following conventions of the lookup method.
%
% See also ComponentBox, clean, lookup, overlay
%
function remove(object,target)

assert(isscalar(object),...
    'ERROR: cannot remove components from more than one box at a time');

% manage input
Narg=nargin();
assert(Narg >= 2,'ERROR: insufficent input');
try
    index=lookup(object,target);
catch ME
    throwAsCaller(ME);
end

% delete requested components
for k=index
    try %#ok<TRYNC>
        delete(object.Component(k));
    end
end
clean(object);

end