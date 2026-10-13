% compareFolders Compare two folders
%
% This *static* method is a front end for MATLAB's visdiff tool dedicated
% to folder comparison.
%    handy.compareFolders(folderA,folderB).
% Optional inputs "folderA" and "folderB" indicate the folders that will
% be compared.  Folders can be specified explicitly (with tab completion!)
% or interactively when empty/omitted.
% 
% See also handy, visdiff
%
function compareFolders(folderA,folderB)

% manage input
Narg=nargin();
if (Narg < 1) || isempty(folderA)
    folderA=uigetdir('','Select folder A');
    if isnumeric(folderA)
        return
    end
else
    assert(isfolder(folderA),'ERROR: invalid folder A');
end

if (Narg < 2) || isempty(folderB)
    folderB=uigetdir('','Select folder B');
    if isnumeric(folderB)
        return
    end
else
    assert(isfolder(folderB),'ERROR: invalid folder B');
end

% perform comparison
visdiff(folderA,folderB);

end