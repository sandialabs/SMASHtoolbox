% set Set system font
%
% This *static* method sets the system font, appropriately applying either
% choose or add
%    calfont.set(name,pixels);
% Optional inputs "name" and "pixels" indicate the desired font and its
% name.  Empty arguments invoke defaults based on the standard uilabel
% font.
%    calfont.set('',pixels); % default font, specified size
%    calfont.set(name,[]); % specified font, default size
%    calfont.set('',[]); % default font/size
%
% Omitting inputs altogether:
%    calfont.add();
% launches interactive font selection with the most recent addition as the
% default choice.
%
% NOTE: calibration may take several seconds, so care should be
% exercised when this method is used inside a loop to set fonts that
% require calibration
%
% See also calfont, choose, add, check
%
% Created Dec, 2025 by Nathan Brown (SNL)
%
function [name,pixels]=set(varargin)

% manage input

try
    [name,pixels]=calfont.check(varargin{:});
catch ME
    throwAsCaller(ME);
end

% set the font, calibrating if necessary

if isempty(calfont.query())
    calfont.add(name,pixels);
else
    info = calfont.get;
    indName = strcmp({info.Calibration.Name}, name);
    indSize = [info.Calibration.Size] == pixels;
    ind = find(indName & indSize, 1);
    if isempty(ind)
        calfont.add(name,pixels,'-choose');
    else
        calfont.choose(ind);
    end
end