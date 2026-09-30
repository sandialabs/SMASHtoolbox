% use Use workspace
%
% This method allows the command window to use a particular workspace.  The
% command:
%    mspace.use(name);
% changes standard MATLAB prompt and passes all typed commands to the named
% workspace.  The command window remains in the workspace until the "exit"
% command is given or the user presses control-C.  All variable additions,
% deletions, and modifications performed when the workspace is in use are
% saved automatically.
% 
% Optional name/value pairs can be used to modify the appearance and
% behavior of workspace use.
%    mspace.use(name,name,value,...);
% Supported options include:
%    'Prompt'       : specify MATLAB prompt (default is workspace name)
%    'PreFunction'  : function called before commmand evaluation 
%    'PostFunction' : function called after command evaluation
% Note that the pre- and post-functions must be defined as function
% handles.
%
% See also mspace, evalin, save, load
%

function use(varargin)

% manage input
if (nargin < 1) || isempty(varargin{1})
    list=mspace.show();
    assert(~isempty(list),'ERROR: no workspaces defined');
    varargin{1}=mspace.select();
    if isempty(varargin{1})
        return
    end
end

option.Name=varargin{1};
varargin=varargin(2:end);
Narg=numel(varargin);
assert(rem(Narg,2) == 0,'ERROR: unmatched name/value pair');
option.Prompt=option.Name;
option.PreFunction='';
option.PostFunction='';
for karg=1:2:Narg
    assert(ischar(varargin{karg}),'ERROR: invalid option name');
    switch lower(varargin{karg})
        case 'prompt'
            assert(ischar(varargin{karg+1}),'ERROR: invalid prompt');
            option.Prompt=varargin{karg+1};
        case 'prefunction'
            assert(isa(varargin{karg+1},'function_handle'),...
                'ERROR: PreFunction must be a function handle');
            option.PreFunction=varargin{karg+1};
        case 'postfunction'
            assert(isa(varargin{karg+1},'function_handle'),...
                'ERROR: PreFunction must be a function handle');
            option.PostFunction=varargin{karg+1};
        otherwise
            error('ERROR: "%" is not a valid option name',varargin{karg});
    end
end
varargin=option;
clear karg Narg option

% load workspace and take commands
if isa(varargin.PostFunction,'function_handle')
    varargin.CU=onCleanup(@() varargin.PostFunction());
end
varargin.Prompt=sprintf('%s: ',varargin.Prompt);
mspace.load(varargin.Name,'-preserve');
loop=true;
while loop
    command=input(varargin.Prompt,'s');
    if isempty(command)
        continue
    end
    command=parse(command);
    if isa(varargin.PreFunction,'function_handle')
        varargin.PreFunction();
    end
    for n=1:numel(command)
        if strcmp(command{n},'exit')
            loop=false;
            break
        end
        try 
            mspace.evalin(varargin.Name,command{n});
        catch ME
            fprintf('ERROR: %s\n',ME.message)
            break
        end
    end
    if isa(varargin.PostFunction,'function_handle')
        varargin.PostFunction();
    end
end

end

function out=parse(in)

switch in(end)
    case {';' ','}
        % do nothing
    otherwise
        in(end+1)=',';
end

out={};
delim=[0 0 0]; % [parenthesis bracket brace]
start=1;
for k=1:numel(in);
    switch in(k)
        case '('
            delim(1)=delim(1)+1;
        case ')'
            delim(1)=delim(1)+1;
        case '['
            delim(2)=delim(2)+1;
        case ']'
            delim(2)=delim(2)-1;
        case '{'
            delim(3)=delim(3)+1;
        case '}'
            delim(3)=delim(3)-1;
        case ','
            if all(delim == 0)
                out{end+1}=in(start:k-1); %#ok<AGROW>
                start=k+1;
            end
        case ';'
            if all(delim == 0)
                out{end+1}=in(start:k); %#ok<AGROW>
                start=k+1;
            end
    end
end

if isempty(out)
    out={in};
end

end