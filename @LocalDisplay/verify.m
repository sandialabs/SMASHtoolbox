% verify Display resolution test
%
% This method displays a resolution test figure.
%    verify(object);
% The figure contains sample text at several sizes and yellow
% metric/imperial rulers generated at the current resolution.  These items
% can be compared to physical objects, such as a piece of paper, to verify
% that the resolution setting is correct.
%
% Sample text is rendered in fixed width font by default (as reported by
% the root graphic).  Alternative fonts can be selected with an optional
% input.
%   verify(object,FontName);
% The input "FontName" can be any font available on the current system.
%
% See also LocalDisplay, measure, set
%
function verify(object,FontName)

% manage input
if (nargin < 2) || isempty(FontName)
    FontName=get(groot,'FixedWidthFontName');
else
    assert(ischar(FontName) || isStringScalar(FontName),'ERROR: invalid font name');
    list=listfonts();
    index=strcmpi(FontName,list);
    assert(any(index),'ERROR: requested font not available');
    FontName=list{index};
end

%
mainpos=get(groot(),'MonitorPositions');
inch2pixel=object.LastSet;
if isempty(inch2pixel)
    inch2pixel=object.Default;
end

previous=findall(groot(),'Tag','LocalDisplay:verify');
if ~isempty(previous)
    delete(previous);
end

margin=10;

name=sprintf('%g DPI resolution test',inch2pixel);
fig=uifigure('Name',name,'WindowStyle','normal','Resize','off',...
    'Visible','off','HandleVisibility','off','Tag','LocalDisplay:verify');
fig.Position(3)=mainpos(1,3)*0.80;

ha(1)=uiaxes(fig,'Units','pixels','Box','on','XGrid','on','Color','y');
ha(1).OuterPosition(1:2)=0;
ha(1).OuterPosition(3)=fig.Position(3);
ha(1).OuterPosition(4)=1*inch2pixel;
xlabel(ha(1),'Inches');
pos=ha(1).InnerPosition;
ha(1).InnerPosition=pos; % prevent future size changes
ha(1).InnerPosition(2)=ha(1).InnerPosition(2)+margin;
pixels=pos(3);
width=pixels/inch2pixel;
xlim(ha(1),[0 width]);
set(ha(1),'XTick',0:0.5:width,'YTick',[]);
disableDefaultInteractivity(ha(1));
ha(1).Toolbar.Visible='off';

ha(2)=copyobj(ha,fig);
ha(2).OuterPosition(2)=sum(ha(1).OuterPosition([2 4]))+margin;
pos=ha(2).InnerPosition;
ha(2).InnerPosition=pos; % prevent future size changes
width=width*25.4; % inch to millimeter
xlim(ha(2),[0 width]);
xlabel(ha(2),'Millimeters');
set(ha(2),'XTick',0:10:width);
disableDefaultInteractivity(ha(2));
ha(2).Toolbar.Visible='off';

FontSize=[10 12 14 16 18]; % points
point2pixel=inch2pixel/object.PointsPerInch;
pos=get(ha(2),'OuterPosition');
pos(1)=margin;
pos(2)=pos(2)+pos(4)+margin;
pos(4)=max(FontSize)*point2pixel*1.20;
FontSize=sort(FontSize);
N=numel(FontSize);
%alphabet=char([48:57 65:90 97:122]);
alphabet=char([48:57 65:90]);
for k=N:-1:1
    label=sprintf('%s (%d points)',alphabet,FontSize(k));
    uilabel(fig,'Text',label,'Position',pos,...
        'FontName',FontName,...
        'FontSize',FontSize(k)*point2pixel);
    pos(2)=pos(2)+pos(4);
end

label=sprintf('Sample text with %s font',FontName);
uilabel(fig,'Text',label,'Position',pos,...
    'FontName',FontName,'FontWeight','bold');
fig.Position(4)=pos(2)+pos(4);
movegui(fig,'center');
figure(fig);

end