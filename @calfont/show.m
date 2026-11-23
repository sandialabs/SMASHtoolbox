% show Display calibrated font
%
% This *static* method displays a calibrated font in a new figure.
%   calfont.show(index);
% Optional input "index" indicates the font to be displayed.  For N
% calibrated fonts, index can be integers 1:N or (-N+1):0, where the latter
% reference backwards from N.  Omitting the input or passing an empty
% value:
%    calfont.show();
%    calfont.show('');
% shows the chosen font.
%
% The generated figure contains two tabs.  The first tab displays
% (editable) sample text, while the second shows calibration plots.
% Requesting outputs:
%    [fig,ht]=calfont.show(...);
% returns graphic handles for the figure and uitabs.
%
% See also calfont, add, choose, lookup, query
%
function varargout=show(varargin)

try
    [cal,~,chosen]=calfont.lookup(varargin{:});
catch ME
    throwAsCaller(ME);
end
name=cal.Name;
pixels=cal.Size;

message=[upper(name(1)) name(2:end)];
label=sprintf('%s %d pixel',message,pixels);
if chosen
    label=[label ' (chosen)'];
end
fig=uifigure('Name',label,'Units','normalized',...
    'Position',[0.1 0.1 0.8 0.8],'Visible','off');
htg=uitabgroup(fig,'AutoResizeChildren','off',...
    'Units','normalized','OuterPosition',[0 0 1 1]);

% 
ht(1)=uitab(htg,'Title','Font calibration','AutoResizeChildren','off');

ha(1)=axes(ht(1),'OuterPosition',[0 0.5 0.5 0.5]);
rows=linspace(0,10,1000);
plot(ha(1),rows,cal.textHeightFcn(rows));
xlabel(ha(1),'Rows');
ylabel(ha(1),'Vertical pixels');
y=cal.boxSizeFcn(1);
yline(ha(1),y);
text(ha(1),max(rows),y,'Box height','VerticalAlignment','bottom',...
    'HorizontalAlignment','right')

ha(2)=axes(ht(1),'OuterPosition',[0.5 0.5 0.5 0.5]);
cols=linspace(0,10,100);
plot(ha(2),cols,cal.textWidthFcn(cols));
xlabel(ha(2),'Columns');
ylabel(ha(2),'Horizontal pixels');
linkaxes(ha,'xy');
xlim(ha,[0 max(rows)]);
y=cal.boxSizeFcn(1);
yline(ha(2),y);
text(ha(2),max(cols),y,'Box width','VerticalAlignment','bottom',...
    'HorizontalAlignment','right')

ha(3)=axes(ht(1),'OuterPosition',[0 0 1 0.5],'Box','on');
x=cal.CharacterData(:,1);
%xb=([min(x) max(x)]);
%xlim(ha(3),xb);
y=cal.CharacterData(:,2);
yb=[min(y) max(y)];
if diff(yb) == 0
    yb=[0.80 1.20];
end
ylim(ha(3),yb);

x1=48;
x2=57;
patch(ha(3),[x1 x2 x2 x1],[yb(1) yb(1) yb(2) yb(2)],'y','LineStyle','none');
xc=(x1+x2)/2;
text(ha(3),xc,yb(2),'0-9','VerticalAlignment','top');

x1=65;
x2=90;
patch(ha(3),[x1 x2 x2 x1],[yb(1) yb(1) yb(2) yb(2)],'c','LineStyle','none');
xc=(x1+x2)/2;
text(ha(3),xc,yb(2),'A-Z','VerticalAlignment','top');

x1=97;
x2=122;
patch(ha(3),[x1 x2 x2 x1],[yb(1) yb(1) yb(2) yb(2)],'m','LineStyle','none');
xc=(x1+x2)/2;
text(ha(3),xc,yb(2),'a-z','VerticalAlignment','top');

hold(ha(3),'on');
plot(ha(3),x,y,'k.');
xlabel(ha(3),'Unicode value');
ylabel(ha(3),'Relative width');

x=87;
xline(ha(3),x,'LineStyle','-','Color','k');
text(ha(3),x,yb(1),'W ','FontWeight','bold',...
     'VerticalAlignment','bottom','HorizontalAlignment','right')

[~,k]=max(cal.CharacterData(:,2));
x=cal.CharacterData(k,1);
xline(ha(3),x,'LineStyle','--','Color','k');
text(ha(3),x,yb(1),char(x),...
     'VerticalAlignment','bottom','HorizontalAlignment','right')

hl=findobj(ht(1),'Type','line');
set(hl,'LineWidth',1);

% 
ht(2)=uitab(htg,'Title','Sample text','AutoResizeChildren','off');
g=uigridlayout(ht(2),'RowHeight',{'1x'},'ColumnWidth',{'1x'},'Padding',0);
message={};
[codes,symbols]=calfont.charset();
message{end+1}=sprintf('There are %d printable characters',numel(codes));
message{end+1}=symbols;
message{end+1}='';
message{end+1}='The quick brown fox jumped over the lazy dog.';
uitextarea(g,'Value',message,'WordWrap','on',...
    'FontName',cal.Name,'FontSize',cal.Size);

htg.Children=ht(end:-1:1);
htg.SelectedTab=ht(2);

figure(fig);

% manage output
if nargout() > 0
    varargout{1}=fig;
    varargout{2}=ht;
end

end