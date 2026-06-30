% reset Remove font calibrations
% 
% This method removes all font calibrations
%    calfont.reset();
%
% NOTE: calibration results take up very little memory, < 3 kB per font
% name/size pair.  Given the time required to add new fonts, clearing
% calibrations is not typically beneficial from a performance perspective.
%
% See also calfont, add, query
%
function reset()

name='calfont';
if isappdata(groot(),name)
    rmappdata(groot(),name);
end

end