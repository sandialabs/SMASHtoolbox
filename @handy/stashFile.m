% stashFile Stash binary file within HDF5 dataset
%
% This *static* method stashes a binary file within an HDF5 dataset.
%    handy.stashFile(source);
% Optional input "source" can be a character array, a cellstr array, or a
% string array of file names to be stashed.  Interactive selection is used
% when this input is empty/omitted, and name filters are specified with an
% asterisk; for example, '*.fig' references all MATLAB figure files in the
% current folder.  
% 
% Bytes from every source file are written to a similarly name file ending
% with  '*_stash.h5'.  For example, the source file 'figure1.fig' is
% written to 'figure1_stash.h5', storing the original file extension
% internally.  Every source is replicated in its own stash file having one
% HDF5 dataset.  These data sets are restored to their original form when
% passed back to this function.
%    handy.stashFile(stash);
% As above, the input "stash" is optional and can be a
% character/cellstr/string array.  The difference is that recovery can only
% be done on '*_stash.h5' files, which cannot themselves be stashed inside
% another file.
%
% The purpose of file stashing to circumvent well-meaning but misguided
% security policies.  For example, MATLAB figure files (*.fig) are a
% legitimate way of transferring data between advanced users, but these may
% be erroneously flagged as suspicious.  To address this problem, one can
% stash their file(s) as HDF5 and send them to a second user.  This second
% user would then convert these HDF5 files back to their original format.
%
% See also handy
%
function stashFile(source)

% manage input
Narg=nargin();
if (Narg < 1) || isempty(source)
    [file,location]=uigetfile({'*.*' 'All files'},...
        'Select file(s)','MultiSelect','on');
    if isnumeric(file)
        fprintf('File stash cancelled\n');
        return
    end
    if ischar(file)
        file={file};
    end
    for n=1:numel(file)
        target=fullfile(location,file{n});
        stashFile(target);
    end
    return
elseif isstring(source) || iscellstr(source)
    for n=1:numel(soure)
        stashFile(source{n});
    end
    return
elseif ischar(source) && contains(source,'*')
    file=dir(source);
    for n=1:numel(file)
        target=fullfile(file(n).folder,file(n).name);
        stashFile(target);
    end
    return
end
assert(ischar(source),'ERROR: invalid file name');
[location,name,ext]=fileparts(source);

% retrieve stashed file
if endsWith(source,'_stash.h5')   
    info=h5info(source);
    assert(isscalar(info.Datasets),'ERROR: too many datasets');
    ds=['/' info.Datasets.Name];
    fprintf('Retrieving %s...',[name ext]);
    data=h5read(source,ds);
    target=ds(2:end);
    [~,name,ext]=fileparts(target);
    counter=0;
    while isfile(target)
        counter=counter+1;
        target=sprintf('%s%d%s',name,counter,ext);
    end
    fid=fopen(target,'w');
    fwrite(fid,data','uint8');
    fclose(fid);
    fprintf('done\n');
    if counter > 0

    end
    return
end

% stash file
assert(~strcmpi(ext,'.h5'),'ERROR: cannot stash *.h5 file');
ds=['/' name ext];

fid=fopen(source,'r');
data=fread(fid,[1 inf],'*uint8');
fclose(fid);
bytes=numel(data);

fprintf('Stashing %s...',[name ext]);
destination=fullfile(location,[name '_stash.h5']);
if isfile(destination)
    delete(destination);
end
h5create(destination,ds,bytes,'Datatype','uint8');
h5write(destination,ds,data);
fprintf('done\n');

end