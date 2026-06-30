% check Verify font request
%
% This *static* method interprets font requests.  The typical calling
% sequence:
%    [name,pixels]=calfont.check(name,pixels);
% verifies that the requested font is available and that the size is valid,
% where "pixels" must be a number >= 3.  Empty values:
%    [name,pixels]=calfont.check('',pixels);
%    [name,pixels]=calfont.check(name,[]);
%    [name,pixels]=calfont.check('',[]);
% are replaced by MATLAB defaults for uilabels.  Calls with no input
% arguments:
%    [name,pixels]=calfont.check();
% invoke interactive font selection.  Style choices (bold, italics, etc.)
% are ignored, and an error is generated when the "OK" button is not
% pressed.
%
% A third input argument allows font size to be specified in terms of
% vertical rows.
%    [name,pixels]=calfont.check(name,value,'rows');
% The output "pixels" is calculated from "value", the display size, and how
% MATLAB renders text on the current system. Requesting more rows makes the
% font smaller, while specifying fewer rows makes the font larger.  This
% calculation is approximate for several reasons.
%    -System toolbars are included in the vertical pixels reported to
%    MATLAB, but these pixels are generally inaccessible for graphics. 
%    -When multiple displays are present, calculations are based in the
%    smallest vertical size.
%    -Results are rounded to the nearest integer. 
% It is not uncommon for one less row than requested to be usable at the
% reported font size.  
%
% See also calfont, add, lookup
%
function [name,pixels]=check(name,value,units)

persistent DefaultName DefaultSize ValidFonts
if isempty(DefaultName)
    fig=uifigure('Visible','off');
    h=uilabel(fig);
    DefaultName=h.FontName;
    DefaultSize=h.FontSize;
    delete(fig);
    ValidFonts=listfonts();
end

data=calfont.get();

Narg=nargin();
if Narg == 0
    if isempty(data)  || isempty(data.Calibration)
        [name,pixels]=pickFont();
    else
        data=data.Calibration(end);
        [name,pixels]=pickFont(data.Name,data.Size);
    end
    assert(~isempty(name),'ERROR: no font selected')
    return
end

if isempty(name)
    name=DefaultName;
else
    assert(ischar(name) || isStringScalar(name),...
        'ERROR: invalid font name');
    k=strcmpi(name,ValidFonts);
    assert(any(k),'ERROR: "%s" font not available on this system',name);
    name=ValidFonts{k};
end

if (Narg < 2) || isempty(value)
    pixels=DefaultSize;
    return
else
    assert(isnumeric(value) && isscalar(value),...
        'ERROR: font size must be a number');
end

if (Narg < 3) || isempty(units) || strcmpi(units,'pixels')
    assert(value >= 2,'ERROR: font size must be a number >= 2 pixels');
    pixels=value;
    return
elseif strcmpi(units,'rows')
    assert(value >= 5,'ERROR: text rows must be a number >= 5');
    rows=value;
else
    error('ERROR: invalid font units')
end

mp=get(groot(),'MonitorPositions');
PixelsPerRow=min(mp(:,4))/rows;

fig=uifigure('Visible','off');
CU=onCleanup(@() delete(fig));
g=uigridlayout(fig,'RowHeight',{'fit'},'ColumnWidth',{'1x'});
Refpixels=20;
h=uilabel(g,'Text','Wg','FontName',name,'FontSize',Refpixels);
RefPixels=h.Position(4);

pixels=PixelsPerRow/RefPixels*Refpixels;
pixels=round(pixels);

end