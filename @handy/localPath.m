% localPath Show local path
%
% This *static* method shows the local path, omitting the many core MATLAB
% folders.  Local additions can be printed in the command window:
%    handy.localPath();
% or returned as a cell array of character vectors.
%    list=handy.localPath();
%
% See also handy, path, matlabroot
%
function varargout=localPath()

% parse system path
source=path;
source(end+1)=pathsep();
stop=strfind(source,pathsep());
N=numel(stop);
list=cell(1,N);
start=1;
for n=1:N
    list{n}=source(start:stop(n)-1);
    start=stop(n)+1;
end

% remove MATLAB stuff
pattern=matlabroot();
keep=false(1,N);
for n=1:N
    if startsWith(list{n},pattern)
        continue
    end
    keep(n)=true;
end
list=list(keep);

% manage output
if nargout() > 0
    varargout{1}=list;
    return
end
fprintf('Local path additions:\n');
fprintf('   %s\n',list{:});

end