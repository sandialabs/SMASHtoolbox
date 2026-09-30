% save Save workspace
%
% This method saves variables and directory/path information from the
% current environement to a workspace.  Standard use:
%    mspace.save(name);
% creates a workspace or overwrites an existing workspace named "name".
% Data should be saved *before* loading a new workspace if it will be
% needed later.
% 
% The default save mode:
%    mspace.save(name,'-wipe'); % same as standard use
% wipes all existing data before saving new data.  New data can be merged
% with existing data in two different ways.
%    mspace.save(name,'-overwrite'); % overwrite old data
%    mspace.save(name,'-preserve'); % keep old data 
% Variables not present in the existing workspace are saved in both merge
% modes.
%
% In standard use, workspaces are saved in memory for quick access later
% on.  Data can also be backed up to a file in the current directory.
%    mspace.save(...,'-backup');
% Backing up to a file is slower than saving data in memory, and
% should only be used in limited circumstances (such as storing a workspace
% for use in a later MATLAB session).
%
% See also mspace, load
% 

function save(name,varargin)

% manage input
if (nargin < 1) || isempty(name)
    name=mspace.select();
    if isempty(name)
        return
    end
end
assert(ischar(name),'ERROR: invalid workspace name');

mode='-wipe';
backup=false;
for n=1:numel(varargin)
    assert(ischar(varargin{n}),'ERROR: invalid workspace option');
    switch lower(varargin{n})
        case '-backup'
            backup=true;
        case {'-wipe' '-overwrite' '-preserve'}
            mode=lower(varargin{1});
        otherwise
            error('ERROR: "%s" is not a valid save option',varargin{1});
    end
end

% manage new/existing names
previous=getSpace();
match=false;
for index=1:numel(previous)
    if strcmp(previous(index).Name,name)
        if previous(index).Locked
            error('ERROR: cannot save to locked workspace "%s"',name);
        end
        new=previous(index);
        match=true;
        break        
    end
end

if ~match || (match && strcmp(mode,'-wipe'))
    new.Name=name;
    new.Description='';
    new.Created=datestr(now);
    new.Modified='';
    new.Locked=false;    
    new.Directory=pwd();
    new.Path=path();
    new.Variable=[];
end

varname=evalin('caller','whos');
for n=1:numel(varname)    
    if strcmp(mode,'-preserve') && isfield(new,varname(n).name)
        warning('mspace:save',...
            'Variable "%s" already in use--keeping previous value',...
            varname{n});
        continue
    elseif strcmp(varname(n).name,'varargin') || strcmp(varname(n).name,'varargout')
        continue
    end
    new.Variable.(varname(n).name)=evalin('caller',varname(n).name);
end

new.Modified=datestr(now);

temp=whos('new');
new.Bytes=temp.bytes;

if isempty(previous)
    previous=new;
elseif match
    previous(index)=new;
else
    previous(end+1)=new;
end
setSpace(previous);

%
if backup
    file=[matlab.lang.makeValidName(name) '.mspace'];
    save(file,'new');
end

end