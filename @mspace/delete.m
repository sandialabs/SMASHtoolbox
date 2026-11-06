% delete Delete workspace
%
% This method requests deletion of a MATLAB space.
%    delete(name);
% Locked spaces *cannot* be deleted, and attempts to do so will generate an
% error.
%
% See also mspace, lock, unlock
%

%
function delete(name)

% manage input
assert(nargin >0,'ERROR: no space name specified');
assert(ischar(name),'ERROR: invalid space name');

% try to delete
found=false;
data=getSpace();
keep=true(size(data));
for n=1:numel(data)
    if strcmp(data(n).Name,name)
        assert(~data(n).Locked,...
            'ERROR: cannot delete locked space "%s"',name);
        keep(n)=false;
        found=true;
        break
    end
end

assert(found,'ERROR: space "%s" does not exist',name);
data=data(keep);
setSpace(data);

end