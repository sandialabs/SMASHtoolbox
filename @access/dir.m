% dir List source folder
%
% This *static* method lists contents of the source folder.  Contents can
% be printed in the command window:
%    access.dir(source);
% or returned as a structure array.
%    list=access.dir(source);
%
% An optional second input may be used for file patterns:
%    access.dir(source,'*.txt'); % only shows *.txt files
% or to list subfolder content.
%    access.dir(source,'/private'); % shows /private subdirectory
% The second input is combined with the source folder and passed to
% MATLAB's dir command.
%
% See also access, dir, edit, getFolder
%
function varargout=dir(source,pattern)

% manage input
assert(nargin >= 1,'ERROR: source must be specified');

if (nargin < 2) || isempty(pattern)
    pattern='*';
else
    pattern=SMASH.Text.text2char(pattern,'ERROR: invalid name pattern');
end

% generate absolute pattern
try
    folder=access.getFolder(source);    
catch ME
    throwAsCaller(ME);
end

pattern=fullfile(folder,pattern);

% manage output
if nargout == 0
    dir(pattern);
else
    varargout{1}=dir(pattern);
end

end