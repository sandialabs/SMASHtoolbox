% check Verify font request
%
% This *static* method interprets font requests.  The typical calling
% sequence:
%    [name,points]=calfont.check(name,points);
% verifies that the requested font is available and that the size is valid,
% where "points" must be a number >= 2.  Empty values:
%    [name,points]=calfont.check('',points);
%    [name,points]=calfont.check(name,[]);
%    [name,points]=calfont.check('',[]);
% are replaced by MATLAB defaults for uilabels.  Calls with no input
% arguments:
%    [name,points]=calfont.check();
% invoke interactive font selection.  Style choices (bold, italics, etc.)
% are ignored, and an error is generated when the "OK" button is not
% pressed.
%
% A third input argument allows font size to be specified in terms of
% vertical rows.
%    [name,points]=calfont.check(name,value,'rows');
% The output "points" is calculated from "value", the display size, and how
% MATLAB renders text on the current system. Requesting more rows makes the
% font smaller, while specifying fewer rows makes the font larger.  This
% calculation is approximate for several reasons.
%    -System toolbars are included in the vertical pixels reported to
%    MATLAB, but these pixels are generally inaccessible for graphics. 
%    -When multiple displays are present, calculations are based in the
%    smallest vertical size.
%    -Results are rounded to the nearest point value. 
% It is not uncommon for one less row than requested to be usable at the
% reported font size.  
%
% See also calfont, add, lookup
%
function [name,points]=check(name,value,units)

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
        report=uisetfont('Select preferred font');
    else
        data=data.Calibration(end);
        default=struct('FontName',data.Name,'FontSize',data.Size);
        report=uisetfont(default,'Select preferred font');
    end
    assert(~isnumeric(report),'ERROR: no font selected');
    name=report.FontName;
    points=report.FontSize;
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
    points=DefaultSize;
    return
else
    assert(isnumeric(value) && isscalar(value),...
        'ERROR: font size must be a number');
end

if (Narg < 3) || isempty(units) || strcmpi(units,'pixels')
    assert(value >= 2,'ERROR: font size must be a number >= 2 points');
    points=value;
    return
else
    assert(value >= 5,'ERROR: text rows must be a number >= 5');
    rows=value;
end

mp=get(groot(),'MonitorPositions');
PixelsPerRow=min(mp(:,4))/rows;

fig=uifigure('Visible','off');
CU=onCleanup(@() delete(fig));
g=uigridlayout(fig,'RowHeight',{'fit'},'ColumnWidth',{'1x'});
RefPoints=20;
h=uilabel(g,'Text','Wg','FontName',name,'FontSize',RefPoints);
RefPixels=h.Position(4);

points=PixelsPerRow/RefPixels*RefPoints;
points=round(points);

end