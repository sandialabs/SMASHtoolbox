% createExample Create local example function
%
% This *static* method creates a local example function and displays this
% copy in the MATLAB editor.
%    ComponentBox.createExample(name);
% Input "name" can be 'message', 'question', 'note', 'browse',
% or 'combine'.  The user is prompted to select an example if this input is
% empty or omitted.
%
% Note: the local example copy is *not* automatically executed.
%
% See also ComponentBox, demonstrate
%
function createExample(name)

valid={'message' 'question' 'note' 'browse' 'combine'};

% manage input
Narg=nargin();
if (Narg < 1) || isempty(name)
    N=numel(valid);
    fprintf('Component box examples\n');
    for n=1:N
        fprintf('   %s\n',valid{n});
    end
    while true()        
        commandwindow();
        name=input('Type example name or q to quit: ','s');
        choice=strtrim(name);
        if strcmp(choice,'q')           
            return
        elseif any(strcmpi(name,valid))
            name=lower(name);
            break        
        end
        fprintf('Invalid choice\n');
    end    
end

% read source file
switch name
    case 'message'
        name='MessageExample.m';
    case 'question'
        name='QuestionExample.m';
    case 'note'
        name='NoteExample.m';
    case 'browse'
        name='BrowseExample.m';
    case 'combine'
        name='CombineExample.m';
end

location=fileparts(mfilename('fullpath'));
location=fullfile(location,'examples');
source=fullfile(location,name);
fid=fopen(source,'r');
source=fscanf(fid,'%c',[1 inf]);
fclose(fid);

% manage namespace
phrase='% import namespace';
location=fileparts(mfilename('fullpath'));
if contains(location,'+')
    ns=extractAfter(location,'+');
    ns=strrep(ns,[filesep() '+'],'.');
    ns=strrep(ns,[filesep() '@'],'.');
    command=['import ' ns];
    source=strrep(source,phrase,command);
else
    source=strrep(source,phrase,'');
end

% create local example copy
target=fullfile(pwd(),name);
[fid,errmsg]=fopen(target,'w');
assert(fid ~= -1,errmsg);

fprintf(fid,'%c',source);
fclose(fid);

fprintf('Created local "%s" example function\n',name);
edit(target);

end