% setFont Set component font
%
% This method sets the font used for component sizing.
%    setFont(object,name,point);
% Optional inputs "name" and  "points" indicate the font to be used when
% new components are added to the box; existing components are not
% affected.  Empty and/or omitted inputs default to the chosen calfont
% setting.
%
% See also ComponentBox, calfont
% 
function setFont(object,varargin)

try
    [~,name,points]=calfont.choose();
catch
    calfont.add('');
    setFont(object,varargin{:});
    return
end
default=struct('Name',name,'Size',points);
if isempty(object.Font)
    object.Font=default;
end

% manage input
Narg=nargin();
if Narg == 1
    varargin={default.Name default.Size};
elseif (Narg == 2) && isstruct(name)
    try 
        temp=name;
        varargin={temp.Name temp.Size};        
    catch
        error('ERROR: invalid font structure');
    end
end

try
    [name,points]=calfont.check(varargin{:});
catch ME
    throwAsCaller(ME);
end

% manage object arrays
if ~isscalar(object)
    for k=1:numel(object)
        setFont(object(k),name,points)
    end
    return
end

% store changes
font.Name=name;
font.Size=points;
object.Font=font;

% update calibration as needed
try
    object.Calibration=calfont.lookup(name,points);
catch
    object.Calibration=calfont.add(name,points,'-choose');
end

end