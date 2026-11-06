% lock Lock workspace
%
% This method locks a workspace, preventing data from being saved to that
% workspace.
%    mspace.lock(name);
% Locked workspaces *cannot* be deleted.
%
% See also mspace, delete, save, unlock
%

function lock(name)

% manage input
assert(nargin >0,'ERROR: no space name specified');
assert(ischar(name),'ERROR: invalid space name');

% perform lock
found=false;
data=getSpace();
for n=1:numel(data)
    if strcmp(data(n).Name,name)
        data(n).Locked=true;
        found=true;
        break
    end
end

assert(found,'ERROR: space "%s" does not exist',name);
setSpace(data);