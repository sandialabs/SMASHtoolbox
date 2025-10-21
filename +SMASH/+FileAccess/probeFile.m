% PROBEFILE Reveal contents of a multi-record file
% 
% This function reveals the contents of multi-record files.  
%    probefile(filename,format);
% The following formats can be used specified when a file is probed.
%     -'agilent' and 'keysight'
%     -'zdas' and 'saturn'
%     -'pff' and 'sda'
%     -'column'
% The default format (if omitted or empty) is 'column'.
%
% When no output is specified (as above), file contents are printed in the
% command window.  This information can be captured as an output structure.
%    report=probeFile(...);
%
% See also SMASH.FileAccess, SupportedFormats
%


% Some formats support a GUI option:
%    >>dlg=probeFile(filename,format,'gui');
% for displaying the contents of a multi-record file.  The output in such
% cases is a handle to the dialog box where the records are displayed.
%
function report=probeFile(filename,format)

% handle file name
Narg=nargin();

if (Narg < 1) || isempty(filename)
    [filename,pathname]=uigetfile({'*.*','All files'},'Select file');
    if isnumeric(filename)
        error('ERROR: no file selected');
    end
    filename=fullfile(pathname,filename);
end
assert(exist(filename,'file')==2,'ERROR: file not found');

if (Narg < 2) || isempty(format)
    format=determineFormat(filename);
end
assert(ischar(format),'ERROR: invalid format');

% probe object
switch format
    case {'acqiris','agilent','keysight','lecroy','tektronix','yokogawa'}
        object=SMASH.FileAccess.DigitizerFile(filename,format);   
    case {'zdas','saturn'}
        object=SMASH.FileAccess.DigitizerFile(filename,format);    
    case 'pff'
        object=SMASH.FileAccess.PFFfile(filename);
    case 'sda'
        object=SMASH.FileAccess.SDAfile(filename);   
    case 'column'
        object=SMASH.FileAccess.ColumnFile(filename);
    case 'block'
        object=SMASH.FileAccess.BlockFile(filename);
    case 'tag'
        object=SMASH.FileAccess.TagFile(filename);
    case 'taf'
        info=SMASH.ThriftyAnalysis.ArrayFile.probe(filename);        
        report.ArraySize=info.Size;
        report.Comments=info.Comments;
        return
    otherwise
        error('ERROR: unable to probe ''%s'' format',format);
end

try
    report=probe(object);
catch ME
    throwAsCaller(ME);
end

end