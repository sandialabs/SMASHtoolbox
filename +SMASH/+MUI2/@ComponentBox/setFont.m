% setFont Set component font
%
% This method sets the font used for component sizing.
%    setFont(object,name,pixels);
% Optional inputs "name" and  "pixels" indicate the font to be used when
% new components are added to the box; existing components are not
% affected.  Empty and/or omitted inputs default to the chosen calfont
% setting.
%
% Font size can be specified in absolute terms (as above) or with respect
% to the current display.
%    setFont(object,name,value,'rows');
% The input "value" indicates the number of components to be vertically
% accommodated on the screen; when multiple displays are present, sizing is
% based on the smallest.  Large row values correspond to smaller fonts,
% i.e. more components can be shown.
%
% NOTE: this method is automatically invoked at object creation, capturing
% the chosen font as the default component font.  Subsequent use of calfont
% methods are *not* automatically detected!  Calling this method with no
% input:
%    setFont(object);
% captures calfont's chosen name and size setting.  This approach is faster
% than explicit font selection, particularly for row-based sizing.
%
% See also ComponentBox, calfont
% 
function setFont(object,varargin)

% manage object arrays
if ~isscalar(object)
    for k=1:numel(object)
        setFont(object(k),varargin{:});
    end
    return
end

% manage input
if isempty(varargin)
    try
        [~,name,pixels]=calfont.choose();
        varargin={name pixels};   
    catch
        new=calfont.add('');
        varargin={new.Name new.Size};
    end
end

try
    object.Calibration=calfont.lookup(varargin{:});
catch 
    try
        object.Calibration=calfont.add(varargin{:});
    catch ME
        throwAsCaller(ME);
    end
end
object.Font.Name=object.Calibration.Name;
object.Font.Size=object.Calibration.Size;

end