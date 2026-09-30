% readWidth Read width specification
%
% This method reads a width specification.
%    inches=readWidth(object,entry);
% The input "entry" can be a value/unit character array, such as '8.5in',
% The output "inches" returns the physical size of the specification in
% inches.  Supported units include inches ('in'), centimeters ('cm'),
% millimeters ('mm'), and points ('pt'). For example:
%    out(1)=readWidth(object,'1in');
%    out(2)=readWidth(object,'25.4mm');
%    out(3)=readWidth(object,'2.54cm');
%    out(4)=readWidth(object,'72.27pt');
% returns a four-element array of ones (within numerical precision).
%
% An optional second input can be used in conjunction with a limited set of
% paper names.
%    inches=readWidth(object,name,orientation);
% Supported names include 'letter' and 'a4'.  The default orientation is
% 'portrait', and 'landscape' is also valid.  For example:
%    inches=readWidth(object,'letter','portrait'); 
% returns the value 8.5.
%
% Additional outputs:
%    [inches,value,unit]=readWidth(object,...);
% return the specified value (as a number) and associated units (character
% array).
%
% See also LocalDisplay
%
function [inches,value,unit]=readWidth(object,entry,orientation)

% manage input
if (nargin < 3) || isempty(orientation) || strcmpi(orientation,'portrait')
    index=1;
elseif strcmpi(orientation,'landscape')
    index=2;
else
    error('ERROR: orientation must be ''portrait'' or ''landscape''');
end

default=8.5;
unit='in';
if (nargin < 2) || isempty(entry)
    value=default;
    entry=sprintf('%g%s',default,unit);
    fprintf('Using default ''%s'' width\n',entry);
elseif strcmpi(entry,'letter')
    value=[8.5 11];
elseif strcmpi(entry,'A4')
    value=[210 297];
    unit='mm';
else
   assert(ischar(entry) || isStringScalar(entry),...
       'ERROR: invalid width specification');
   buffer=entry;
   [value,count,~,next]=sscanf(buffer,'%g',1);
   assert((count == 1) && (value > 0),'ERROR: invalid physical width');
   unit=strtrim(buffer(next:end));
   assert(any(strcmpi(unit,{'in' 'cm' 'mm' 'pt'})),'ERROR: invalid width unit');   
end

if ~isscalar(value)
    value=value(index);
end

switch lower(unit)
    case 'in'
        inches=value;
    case 'mm'
        inches=value/object.MillimetersPerInch;
    case 'cm'
        inches=value/object.MillimetersPerInch*10;
    case 'pt'
        inches=value/object.PointsPerInch;        
end