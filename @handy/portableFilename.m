% portableFilename Generate portable file name
%
% This *static* method makes a file name valid on any operating system.
%    result=handy.portableFilename(suggestion);
% The output "result" is a character array based on the input "suggestion",
% using the current date/time when this input is omitted or empty.
% Problematic characters are replaced by underscores so that the result
% contains only alphanumeric characters (0-9, A-Z, and a-z), hyphens,
% periods, and underscores.
%
% See also handy
%
function out=portableFilename(in)

% manage input
if (nargin() < 1) || isempty(in)
    stamp=datevec(datetime('now'));
    stamp=round(stamp);
    in=sprintf('file%04d%02d%02dT%02d%02d%02d',stamp);    
elseif isStringScalar(in)
    in=char(in);
else
    assert(ischar(in),'ERROR: invalid file name');
end

% process suggestion
out=in;
valid=uint8([45 46 48:57 65:90 95 97:122]);
for n=1:numel(out)
    if any(uint8(out(n)) == valid)
        continue
    end
    out(n)='_';
end

end