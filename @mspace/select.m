% select Select workspace name
%
% This method prompts the user to select the name of an existing workspace.
%    name=mspace.select();
% Selecting a name does *not* load data from or save data to a
% workspace!  Interactive selection is provided for convenience only. 
%
% See also mspace
%

function choice=select()

list=mspace.show();

choice=listdlg('Name','Select space',...
    'PromptString','Select MATLAB space:',...
    'ListString',list,'SelectionMode',1);

if ~isempty(choice)
    choice=list{choice};
end

end