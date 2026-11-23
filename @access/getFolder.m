% getFolder Get source folder
%
% This *static* method gets the folder containing the requested source.
%    folder=access.getFolder(source);
% The input "source" can be any file, class, or package name.  The output
% "folder" is the absolute folder name for the source file/class/package.
%
% See also access, dir
%
function folder=getFolder(source)

% manage input
assert(nargin > 0,'ERROR: source must be specified');

% simple solution
try
    folder=which(source);
    if startsWith(folder,'built-in (')
        folder=extractBetween(folder,'(',')');
        folder=folder{1};
    end
    while ~isempty(folder)
        if isfolder(folder)
            return
        end
        folder=fileparts(folder);        
    end
catch
    error('ERROR: invalid source request');
end

% harder solution
data=meta.package.fromName(source);
assert(~isempty(data),'ERROR: unable to find requested source');

fs=filesep();
target=[fs '+' strrep(data.Name,'.',[filesep '+'])];

match=false;
list=path();
separator=pathsep();
while ~isempty(list)
    folder=extractBefore(list,separator);
    folder=fullfile(folder,target);
    if isfolder(folder)
        match=true;
        break
    end
    list=extractAfter(list,separator);
end

assert(match,'ERROR: unable to find requested source');

end