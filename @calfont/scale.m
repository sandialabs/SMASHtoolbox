% scale Font scaling correction
%
% This *static* method manages the font scaling correction.  Newer graphic
% components (uilabel, uibutton, etc.) display fonts systematically smaller
% than legacy uicontrols and axes/uiaxes text at the same font size.  The
% discrepancy is consistent the 96/72 (1.33x) scaling mentioned in the
% R2025a release notes for Mac users, but the problem predates that release
% and has been observed on all platforms. Until the issue is officially
% resolved, JavaScript graphic components must be manually scaled for
% visual consistency.
%
% Calling this method with no input returns the font scaling factor for the
% current environment.
%    value=calfont.scale();
% The output "value" is a numeric scalar.  Developers can use this value to
% match component text sizes with font calibrations, which incorporate
% the correction automatically.  Omitting the output:
%    calfont.scale();
% prints the scaling factor in the command window with the current system 
% architecture (e.g., MACA64 for a Silicon Mac).
%
% The font factor can be modified by passing an input argument.
%    calfont.scale(value);
% The input "value" must be a number > 0.  Changes should not be made
% lightly, certainly not before noting the original value beforehand.  The
% default setting can only be restored by:
%    munlock('calfont.scale'); clear all;
% or starting a new MATLAB session.
%
% See also calfont, add, reset
% 
function varargout=scale(value)

mlock
persistent correction
if isempty(correction)
    default=96/72;
    switch upper(computer())
        case 'PCWIN64'
            correction=default;
        case 'GLNXA64'
            correction=default;
        otherwise % Intel and Silicon Macs
            correction=default;
    end
end

if nargin() > 0
    assert(isnumeric(value) && isscalar(value) && value > 0,...
        'ERROR: invalid font scaling');
    if value ~= correction
        correction=value;
        calfont.reset();
    end
    return
end

if nargout() == 0
    commandwindow();
    fprintf('Font scale correction set to %g (%s)\n',...
        correction,computer());
else
    varargout{1}=correction;
end

end