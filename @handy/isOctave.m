% isOctave Detect Octave
%
% This *static* method determines if the current environment is Octave
% rather than MATLAB.
%   value=handy.isOctave();
% The output "value" is true when Octave is running and otherwise false.
% 
% See also handy
%
function value=isOctave()

persistent OV
if isempty(OV)
    OV=logical(exist ("OCTAVE_VERSION", "builtin"));
end
value=OV;

end