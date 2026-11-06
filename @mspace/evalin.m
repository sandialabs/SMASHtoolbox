% evalin Evaluate command(s)
%
% This method evaluates MATLAB commands in the specified workspace.
%    mspace.evalin(name,command); % simple/compound commands with no outputs
%    [out1,out2,...]=mspace.evalin(name,command); % single command with outputs
% Workspace modications that occur during command evaluation are
% automatically saved.
%
% See also mspace, save
%

function varargout=evalin(varargin)

% manage input
assert(nargin >0,'ERROR: no space name specified');
assert(ischar(varargin{1}),'ERROR: invalid space name');

% perform evaluation
varargin{3}=pwd;
varargin{4}=onCleanup(@() cd(varargin{3}));

try
    mspace.load(varargin{1},'-preserve');
catch ME
    throw(ME);
end

try
    if nargout == 0
        eval(varargin{2});
    else
        varargout=cell(1,nargout);
        [varargout{:}]=eval(varargin{2});        
    end
catch ME
    throwAsCaller(ME);
end

mspace.save(varargin{1});

end