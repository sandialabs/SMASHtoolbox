% sysopen Open item in local OS
%
% This *static* method opens a specified file/folder item in the local
% operating system (outside of MATLAB).
%   handy.sysopen(name);
% Optional input "name" indicate the item to be opened by character array
% or scalar string, defaulting to the current folder.
%
% Wildcard patterns can be used specify multiple items at one.
%    handy.sysopen(pattern);
% For example, the pattern '*.png' opens all files with the '.png'
% extension with the system's default program.
%
% See also handy, winopen
%
function sysopen(name)

% manage input
if (nargin() < 1) || isempty(name)
    name={pwd()};
elseif ischar(name)
    name={name};
else
    assert(isStringScalar(name),'ERROR: invalid name');    
end

% manage wildcards
if contains(name{1},'*')
    list=dir(name{1});
    assert(~isempty(list),'ERROR: no match found for "%s"',name{1});
    name=cell(size(list));
    for n=1:numel(list)
        name{n}=fullfile(list(n).folder,list(n).name);
    end    
end

% open named item(s)
for n=1:numel(name)
    try
        if ispc()
            winopen(name{n});
            return
        elseif ismac()
            command=sprintf('open "%s"',name{n});
        else
            command=sprintf('xdg-open "%s"',name{n});
        end
        [status,out]=system(command);
        assert(status == 0,'ERROR: %s',out);
    catch ME
        throwAsCaller(ME);
    end
end

end