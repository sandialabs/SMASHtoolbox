% truncate Trim file(s) to specified byte length
%
% This function truncates an existing file to a specified byte length.
%    truncate(file,bytes);
% Mandatory input "file" indicate the file (character array) or files
% (cellstr or string array) to be truncated.  Mandatory input "bytes"
% indicates the number of bytes (non-negative integer) the file(s) will be
% trimmed to.
%
% See also handy
%
function truncate(file,bytes)

persistent script
if isempty(script)
    location=fileparts(mfilename('fullpath'));
    script=fullfile(location,'truncate.pl');
end

% manage input
assert(nargin() == 2,'ERROR: invalid number of inputs');
if ischar(file)
    file={file};
elseif isstring(file)
    file=cellstr(file);
else
    assert(iscellstr(file),'ERROR: invalid file request'); %#ok<ISCLSTR>
end

assert(isnumeric(bytes) && isscalar(bytes) ...
    && isfinite(bytes) && (bytes >= 0),...
    'ERROR: invalid number of bytes');
bytes=ceil(bytes);
ByteString=sprintf('%.0f',bytes);

for n=1:numel(file)
    assert(isfile(file{n}),'ERROR: file not found');
    list=dir(file{n});   
    if list(n).bytes <= bytes
        %warning('truncate:tooshort',...
        %    'Did not truncate "%s" because it is already <= %d bytes',list(1).name,bytes);
        %continue
    end
    target=fullfile(list(1).folder,list(1).name);
    [errmsg,status]=perl(script,target,ByteString);
    if status ~= 0
        fprintf('There was a problem truncating "%s"\n',list(1).name);
        fprintf(errmsg);
    end
end

end