% describe Describe workspace
%
% This method adds/modifies the description associated with a workspace.
%    describe(name,value);
%
% See also mspace
%

function describe(name,value)

% manage input
assert(nargin > 0,'ERROR: no space name specified');
assert(ischar(name),'ERROR: invalid space name');

assert(nargin == 2,'ERROR: no description specified');
assert(ischar(value),'ERROR: invalid description');

% add description
found=false;
data=getSpace();
for n=1:numel(data)
    if strcmp(data(n).Name,name)
        data(n).Description=value;
        found=true;
        break
    end
end

assert(found,'ERROR: space "%s" does not exist',name);
setSpace(data);