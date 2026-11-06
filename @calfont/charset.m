% charset Show/manage printable character set
%
% This *static* method returns the printable character codes and the
% corresponding symbols.
%   [codes,symbols]=calfont.charset();
% For example, the code value 87 represents the letter "W".  Method calls
% with no output:
%    calfont.charset();
% print the current character set in the command window.
%
% The printable character set may be defined with one or more input
% arguments.
%    calfont.charset(arg1,arg2,...);
% Each argument can be a string array, a cell array of character vectors, a
% character array, or a numeric array; numeric values must be within the
% set of unsigned 16-bit integers (0:65535).  The default set is based on
% the printable ASCII characters (32:126), which can be requested by
% itself:
%    calfont.charset('ascii');  % input not case sensitive
% or in conjunction with additional Unicode characters.
%    calfont.charset('ascii',extra1,extra2,...);
%
% NOTE: character set changes reset all font calibrations.
%
% See also calfont, reset
%
function varargout=charset(varargin)

persistent codes ASCII
if isempty(codes)
    ASCII=single(32:126);
    codes=ASCII;
end

% manage input
Narg=nargin();
if Narg > 0
    new=[];
    for n=1:Narg
        arg=reshape(varargin{n},1,[]);
        if strcmpi(arg,'ascii')
            new=[new ASCII]; %#ok<AGROW>
            continue
        end
        if isstring(arg) || iscellstr(arg)
            for k=1:numel(arg)
                new=[new single(temp)]; %#ok<AGROW>
            end
        elseif ischar(arg)
            new=[new single(arg)]; %#ok<AGROW>
        elseif isnumeric(arg)
            valid=0:intmax('uint16');
            for k=1:numel(arg)
                assert(any(arg(k) == valid),...
                    'ERROR: invalid Unicode request');
            end
            new=[new single(arg)]; %#ok<AGROW>
        else
            error('ERROR: invalid character input');
        end
    end    
    if ~any(codes == 87)
        codes(end+1)=87;        
    end
    new=unique(new);
    if ~isequal(codes,new)
        codes=new;
        calfont.reset();        
    end
end
symbols=char(codes);

% manage output
if nargout() > 0
    varargout{1}=codes;
    varargout{2}=symbols;
    return
end

commandwindow();
fprintf('Printable characters\n');
fprintf('%5s %5s\n','Code','Symbol');
for n=1:numel(codes)
    fprintf('%5d %5s\n',codes(n),symbols(n));
end

end