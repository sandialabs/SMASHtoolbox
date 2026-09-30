% splitFile Break file into pieces for later recombination
%
% This *static* method generates split files from a specified source.
%    handy.splitFile(source,maxsize);
% Optional input "source" indicates the file to be split.  The user is
% prompted to select a file when this input is empty or omitted.
%
% Optional input "maxsize" controls the maximum split file size, defaulting
% to 10 MB and interpreting numeric input as megabytes.  Maximum size can
% also be specified with characters '(number)(unit)'.  Units are denoted by
% a case-insensitive prefix character followed by a lower-case 'b' (bits)
% and upper-case 'B' (bytes).  Valid prefixes (case insensitive) include
% 'K' (kilo), 'M' (mega), 'G' (giga) and 'T' (tera).
%
% Files created by this method retain the source file name/extension
% followed by a dash, an integer, and the '.split' extension.  The integer
% format is based on the number of split files created, maintaining a fixed
% number of digits throughout.  For example, the file "src.bin" creates
% "src.bin-1.split" through "src.bin-N.split" as long as N < 10, but two
% digits ("src.bin-01.split") are used for N=10 through N=99. Previously
% created file are *not* automatically deleted when a file is re-split with
% a different maximum size.  Excess *.split files may be need to be
% manually removed to prevent interference between different split file
% sets.
%
% Passing any *.split file back to this method restores the source file.
%    handy.splitFile(piece);
% Usually a source file "src.bin" is restored using "src.bin-1.split" (when
% N < 10 as described above), but any other file in the group could be
% used. The important thing is that all *.split files be located in the
% same folder.  Recombined files do not overwrite the original, if
% present; a unique file is generated from the original name as needed.
%
% NOTE: this method will *not* allow *.split files to further split.
%
% See also handy
%
function splitFile(src,maxsize)

% manage input
Narg=nargin();
if (Narg < 1) || isempty(src)
    [name,location]=uigetfile({'*.*' 'All files'},...
        'Select source file','MultiSelect','off');
    if isnumeric(name)
        return
    end
    src=fullfile(location,name);
else
    assert(ischar(src) || isStringScalar(src),...
        'ERROR: invalid source file');
end

[~,~,ext]=fileparts(src);
if strcmpi(ext,'.split')
    assert(Narg < 2,'ERROR: cannot split *.split files');
    try
        combineFile(src);
    catch ME
        throwAsCaller(ME);
    end
    return
end

if (Narg < 2) || isempty(maxsize)
    maxsize=10*uint64(1024)^2; % 1 MB
elseif isnumeric(maxsize)
    maxsize=uint64(maxsize)*uint64(1024)^2; % megabytes
else
    if isStringScalar(maxsize)
        maxsize=char(maxsize);
    else
        assert(ischar(maxsize),'ERROR: invalid max size');
    end
    [number,count,~,next]=sscanf(maxsize,'%g',1);
    assert(count  == 1,'ERROR: invalid number max size');
    maxsize=strtrim(maxsize(next:end));
    try
        switch lower(maxsize(1))
            case 'k'
                exponent=1;
            case 'm'
                exponent=2;
            case 'g'
                exponent=3;
            case 't'
                exponent=4;
            otherwise
                error('');
        end
        switch maxsize(2)
            case 'b'
                chunk=1000;
            case 'B'
                chunk=1024;
            otherwise
                error('');
        end
    catch 
        error('ERROR: invalid unit');
    end
    maxsize=number*chunk^exponent;
end

% perform split
try
    in=fopen(src,'r');
catch ME
    throwAsCaller(ME);
end
CU=onCleanup(@() fclose(in));
[~,name,ext]=fileparts(src);

report=dir(src);
N=ceil(report.bytes/maxsize);
if N == 1
    warning('Source file could fit in one split file');
end
digits=calculateDigits(double(N));
format=sprintf('%s-%%0%dd.split',[name ext],digits);

for n=1:N
    [buffer,~]=fread(in,maxsize);
    target=sprintf(format,n);
    out=fopen(target,'w');
    fwrite(out,buffer);
    fclose(out);
end

end

function value=calculateDigits(number)

% manage input
Narg=nargin();
assert(Narg > 0,'ERROR: insufficient input');
assert(isnumeric(number) && isreal(number) && all(isfinite(number)),...
    'ERROR: invalid input');

% calculation
number=abs(number);
if any(number ~= round(number))
    warning('digits:integers','Non-integer value detected');
end
number=max(round(number));

value=log10(number);
if value == ceil(value)
    value=value+1;
else
    value=ceil(value);
end

end

%%
function combineFile(name)

% manage input
if (nargin() < 1) || isempty(name)
    [name,location]=uigetfile({'*.split;*.SPLIT' 'Split files (*.split)'},...
        'Select split file','MultiSelect','off');
    if isnumeric(name)
        return
    end 
    name=fullfile(location,name);

else
    assert(ischar(name) || isStringScalar(name),...
        'ERROR: invalid split file');
    assert(isfile(name),'ERROR: split file not found');
end

% find split files
[location,name,ext]=fileparts(name);
assert(strcmpi(ext,'.split'),'ERROR: invalid split file');
if isempty(location)
    location=pwd();
end
k=strfind(name,'-');
name=name(1:k(end)-1);
pattern=fullfile(location,[name '-*.split']);
list=dir(pattern);
assert(~isempty(list),'ERROR: requested file split not found');

% merge split files
target=tempname();
out=fopen(target,'w');
for n=1:numel(list)
    temp=extractAfter(list(n).name,name);
    m=sscanf(temp(2:end),'%g',1);
    assert(m == n,'ERROR: invalid numbering on file "%s"',list(n).name);
    in=fopen(fullfile(list(n).folder,list(n).name),'r');
    buffer=fread(in,inf);
    fclose(in);
    fwrite(out,buffer);
end
fclose(out);

if isfile(name)
    fprintf('Original file already exists, making another copy...');
    counter=0;
    while true()
        counter=counter+1;
        new=sprintf('%s copy %d',name,counter);
        if isfile(new)
            continue
        end
        name=new;
        fprintf('done\n');
        break
    end
end
copyfile(target,name);
delete(target);

end