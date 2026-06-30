% unlock Unlock workspace
%
% This method unlocks a workspace, allowing data to be saved to the
% workspace.
%    mspace.lock(name);
% Unlocked objects can be deleted.
%
% See also mspace, delete, save, unlock
%

function unlock(name)

% manage input
assert(nargin >0,'ERROR: no space name specified');
assert(ischar(name),'ERROR: invalid space name');

% perform unlock
found=false;
data=getSpace();
for n=1:numel(data)
    if strcmp(data(n).Name,name)
        data(n).Locked=false;
        found=true;
        break
    end
end

assert(found,'ERROR: space "%s" does not exist',name);
setSpace(data);