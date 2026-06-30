% load Load workspace
%
% This method loads information from a workspace into a local environment.
%    mspace.load(name);
% Load requests search memory first for the named workspace.  If no match
% is found, the current directory is searched for workspace backup.
%
% By default, the local environment is cleared before loading data from the
% workspace.  Workspace variables can also be merged into the local
% environment.
%    mspace.load(name,'-wipe'); % same as standard mode
%    mspace.load(name,'-overwrite'); % overwrite environment with workspace as needed
%    mspace.load(name,'-preserve'); % keep environment variables when conflicts occur
% Specific information can also be loaded from a workspace.
%    mspace.load(name,'-variable'); % variables only
%    mspace.load(name,'-directory'); % directory only
%    mspace.load(name,'-path'); % path only
%    mspace.load(name,'-variable','-diretory'); % variables and directory
%    mspace.load(name,'-all'); % load everything (default)
% 
% Requesting an output returns a structure with all workspace information.
%    previous=mspace.load(name);
%
% See also mspace, save
%

function varargout=load(name,varargin)

% manage input
assert(nargin >= 1,'ERROR: no mspace name specified');
assert(ischar(name),'ERROR: invalid mspace name');

mode='-wipe';
LoadFlag=nan(1,3); % [data directory path]
for n=1:numel(varargin);
    assert(ischar(varargin{n}),'ERROR: invalid mspace option');
    switch lower(varargin{n})
        case {'-wipe' '-overwrite' '-preserve'}
            mode=lower(varargin{1});
        case '-all'
            LoadFlag=true(1,4);
        case {'-variable' '-var'}
            LoadFlag(1)=true;
        case {'-directory' '-dir'}
            LoadFlag(2)=true;
        case '-path'
            LoadFlag(3)=true;
        otherwise
            error('ERROR: "%s" is not a valid load option',varargin{1});
    end
end

if any(LoadFlag)
    LoadFlag(isnan(LoadFlag))=false;
else
    LoadFlag=true(1,3);
end

% get requested space
data=getSpace();
found=false;
for n=1:numel(data)
    if strcmp(data(n).Name,name)
        data=data(n);
        found=true;
        break
    end
end

if ~found
    try
        file=[matlab.lang.makeValidName(name) '.mspace'];
        data=load(file,'-mat');
        data=data.new;
    catch
        error('ERROR: space "%s" does not exist',name);
    end
end


% manage output
if nargout == 0
    if LoadFlag(1)
        if strcmp(mode,'-wipe')
            evalin('caller','clear variables');            
        end
        varname=fieldnames(data.Variable);
        for n=1:numel(varname)
            if strcmp(mode,'-preserve')
                temp=sprintf('exist(''%s'',''var'')',varname{n});
                if evalin('caller',temp)
                    warning('mspace:load',...
                        'Variable "%s" already in use--keeping previous value',...
                        varname{n});
                    continue
                end
            end
            assignin('caller',varname{n},data.Variable.(varname{n}));                
        end
        if ~found
            previous=getSpace();
            previous(end+1)=data;
            setSpace(previous);
        end
    end
    if LoadFlag(2)
        cd(data.Directory);
    end
    if LoadFlag(3)
        path(data.Path);
    end
else
    varargout{1}=data;
end

end