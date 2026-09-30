% edit Edit source folder file
%
% This *static* method opens a specified file from the source folder in the
% MATLAB editor.
%    access.edit(source,file);
%
% See also access, dir, getFolder
%
function edit(source,file)

% manage input
assert(nargin == 2,'ERROR: two inputs required');
file=SMASH.Text.text2char(file,'ERROR: invalid file name');

% generate absolute name
try
    folder=access.getFolder(source);
catch ME
    throwAsCaller(ME);
end

file=fullfile(folder,file);
edit(file)

end