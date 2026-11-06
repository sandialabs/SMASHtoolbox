function object=selectCurrent(object,target)

persistent figtools
if isempty(figtools)
    figtools=packtools.import('SMASH.Graphics.FigureTools.*');
end

%% display figure with existing ROI (if present)
fig=ancestor(target,'figure');
figure(fig);
selection=view(object,target);

persistent ZoomPan
if isempty(ZoomPan)
    local=packtools.import('.*');
    ZoomPan=local.ZoomPan;
end
ZPstate=ZoomPan('state');
ZoomPan(fig,'on');

CurrentPoint=1;
width=max(selection.LineWidth,2);
scale=2;
highlight=line('Parent',target,...
    'Marker','none','LineWidth',scale*width,'Visible','off');

previous.KeyPress=get(fig,'WindowKeyPressFcn');
previous.ButtonDown=get(fig,'WindowButtonDownFcn');
previous.ButtonUp=get(fig,'WindowButtonUpFcn');
previous.Motion=get(fig,'WindowButtonMotionFcn');

set(fig,'WindowKeypressFcn',@keypress,'WindowButtonDownFcn',@mousepress,...
    'WindowButtonUpFcn','','WindowButtonMotionFcn','')
    function keypress(src,EventData)
        switch lower(EventData.Key)
            case {'enter' 'return'}
                figure(cb.Figure);                            
            case {'backspace' 'delete'}
                if isempty(CurrentPoint)
                    return
                end
                keep=true(size(object.Data,1),1);
                keep(CurrentPoint)=false;
                object=define(object,object.Data(keep,:));
                if CurrentPoint > 1
                    CurrentPoint=CurrentPoint-1;
                end
                update();
            otherwise
                try
                    previous.KeyPress(src,EventData);
                catch
                end
        end
    end
function mousepress(~,~)      
        switch get(fig,'SelectionType')
            case 'normal'                
                pos=getNearestTargetPoint();
                if isempty(pos)
                    return
                end
                data=object.Data;
                data(end+1,:)=pos;                
                [object,index]=define(object,data);
                [~,CurrentPoint]=max(index);                
            case 'extend'
                if isempty(object.Data)
                    return
                end
                pos=getNearestTargetPoint();
                if isempty(pos)
                    return
                end
                index=getNearestIndex(pos);
                keep=true(size(object.Data,1),1);
                keep(index)=false;
                object=define(object,object.Data(keep,:));
                if CurrentPoint > 1
                    CurrentPoint=CurrentPoint-1;
                end        
            case 'alt' % control-click
                pos=getNearestTargetPoint();
                if isempty(pos)
                    return
                end
                index=getNearestIndex(pos);                
                CurrentPoint=index;
        end
        set(Selection(2),'ValueIndex',1);
        update();
    end 
    function value=getNearestTargetPoint()
        value=[];
        for kk=1:numel(target)
            if target(kk) ~= fig.CurrentAxes
                continue
            end
            temp=get(fig.CurrentAxes,'CurrentPoint');
            temp=temp(1,1:2);
            bound=get(fig.CurrentAxes,'XLim');
            if (temp(1) < bound(1)) || (temp(1) > bound(2))
                return
            end
            bound=get(fig.CurrentAxes,'YLim');
            if (temp(2) < bound(1)) || (temp(2) > bound(2))
                return
            end
            value=temp;
            break            
        end             
    end
    function index=getNearestIndex(pos)
         xb=get(fig.CurrentAxes,'XLim');
         yb=get(fig.CurrentAxes,'YLim');
         L2=object.Data(:,1:2)-pos;
         L2(:,1)=L2(:,1)/diff(xb);
         L2(:,2)=L2(:,2)/diff(yb);
         L2=sum(L2.^2,2);
         [~,index]=min(L2);
    end
    
%% create dialog
cb=SMASH.MUI2.ComponentBox();
font=struct('Name','','Size',14);
try %#ok<TRYNC>
    Q=calfont.lookup();
    font.Name=Q.Name;
    font.Size=Q.Size;    
end
setFont(cb,font.Name,font.Size);setName(cb,'ROI settings');

Name=addEdit(cb,20);
Name(3)=addButton(cb,10);
set(Name(1),'Text','Name:');
set(Name(2),'Value',object.Name,'ValueChangedFcn',@changeName);
set(Name(3),'Text','Comments','ButtonPushedFcn',@changeComments);
    function changeName(varargin)
        object.Name=get(Name(2),'Value');
    end
set(Name(3),'ButtonPushedFcn',@changeComments)
    function changeComments(varargin)
        object=comment(object);
    end
newRow(cb);

%Selection=addblock(dlg,'popup_button',{'Current point:' ' Remove '},{'()'},20);
%set(Selection(2),'Callback',@changePoint);
Selection=addDropdown(cb,20);
Selection(3)=addButton(cb,8);
set(Selection(1),'Text','Current point:');
set(Selection(2),'ValueChangedFcn',@changePoint);
function changePoint(varargin)
        index=get(Selection(2),'ValueIndex');
        CurrentPoint=index;        
        x=object.Data(index,1);
        y=object.Data(index,2);
      
        switch object.Mode
            case 'x'
                temp=sprintf('%g',x);
                set(Coordinate,'Value',temp,'UserData',temp);
                xdata = [x x];
                ydata = [target.YLim(1) target.YLim(2)];
            case 'y'
                temp=sprintf('%g',y);
                set(Coordinate,'Value',temp,'UserData',temp);
                ydata = [y y];
                xdata = [target.XLim(1) target.XLim(2)];
        end
        set(highlight,'XData',xdata,'YData',ydata,'Visible','on');
    end  
set(Selection(3),'Text','Remove','ButtonPushedFcn',@removePoint);
    function removePoint(varargin)
        index=CurrentPoint;
        keep=true(size(object.Data,1),1);
        keep(index)=false;
        object=define(object,object.Data(keep,:));       
        CurrentPoint=min(CurrentPoint,size(object.Data,1)); 
        update()
    end
newRow(cb);

switch object.Mode
    case 'x'
        label=get(get(target,'XLabel'),'String');
        if isempty(label)
            label='x';
        end        
    case 'y'
        label=get(get(target,'YLabel'),'String');
        if isempty(label)
            label='y';
        end        
end
label=strtrim(label);
if label(end) ~= ':'
    label=[label ' :'];
end
h=addEdit(cb,20);
set(h(1),'Text',label);
set(h(2),'ValueChangedFcn',@checkValue);
Coordinate=h(end);
    function checkValue(src,~)
        in=sscanf(get(src,'Value'),'%s',1);
        set(src,'Value',in);
        value=sscanf(in,'%g',1);
        if isempty(value)
            set(src,'Value',get(src,'UserData'))            
        else
            set(src,'UserData',in);
            temp(1)=sscanf(get(Coordinate,'Value'),'%g',1);
            object.Data(CurrentPoint,:)=temp;
            update();
        end
    end
newRow(cb);

Button(1)=addButton(cb,10);
set(Button(1),'Text','Use mouse','ButtonPushedFcn',@useMouseButton);
%set(cb.Figure,'KeyPressFcn',@useMouseButton);
    function useMouseButton(varargin)
        figure(fig); % what if the target was deleted?
    end
Button(2)=addButton(cb,10);
set(Button(2),'Text','Help','ButtonPushedFcn',@mouseHelp);
    function mouseHelp(varargin)
        figtools.focus('off');
        new=findall(groot,'Type','figure','Tag','PointsSelectHelp');
        if isempty(new)
            junk=SMASH.MUI2.ComponentBox();
            setFont(junk,font.Name,font.Size);
            setName(junk,'Use mouse');
            summary{1}='Click mouse to select points, press return when finished.';
            summary{end+1}='Delete key removes current point; shift-click removes nearest point.';
            summary{end+1}='Control-click makes the nearest point current.';
            summary{end+1}='Use arrow keys to pan, shift-arrow keys to zoom.';
            summary{end+1}='Press "a" to auto scale, "t" to tight scale';
            h=addTextarea(junk,40,4);
            set(h(1),'Text','Instructions:');
            set(h(2),'Value',summary,'ValueChangedFcn'...
                ,@(src,~) set(src,'Value',summary));
            fit(junk);
            locate(junk,'center',cb.Figure);
            show(junk);
            junk.Figure.Tag='PointsSelectHelp';
            figtools.focus([new cb.Figure fig]);            
        end
        figtools.focus([new cb.Figure fig]);
    end
newRow(cb);

Button(3)=addButton(cb,10);
set(Button(3),'Text','Done','ButtonPushedFcn',@doneButton)
    function doneButton(varargin)
        delete(cb);
        h=findall(groot(),'Type','figure','Tag','PointsSelectHelp');        
        delete(h);
    end
set(cb.Figure,'DeleteFcn',@doneButton);

%% show dialog
update();
fit(cb);
locate(cb,'center',fig);
show(cb);
figtools.focus([cb.Figure fig]);
waitfor(cb.Figure);
figtools.focus('off');

if ishandle(fig)
    delete(selection);
    delete(highlight);
    set(fig,'WindowKeyPressFcn',previous.KeyPress,...
        'WindowButtonDownFcn',previous.ButtonDown,...
        'WindowButtonUpFcn',previous.ButtonUp,...
        'WindowButtonMotionFcn',previous.Motion);
    if strcmp(ZPstate,'off')
        ZoomPan(fig,'off');
    end
end

%% utility functions
    function update()
        if isempty(object.Data)      
            set(Selection(2),'Enable','off','Items',{'(none selected)'});
            selection.Visible='off';
            set(highlight,'Visible','off');
            CurrentPoint=0;
            set(Coordinate,'Enable','off','Value','');            
            return
        end
        %
        data=object.Data;
        x = data(:,1); y=data(:,2);
        switch object.Mode
        case 'x'
            xdata = [x(:)';x(:)';x(:)'.*inf];
            ydata = [0.*x(:)'+target.YLim(1);0.*x(:)'+target.YLim(2);x(:)'.*inf]; 
        case 'y'
            ydata = [y(:)';y(:)';y(:)'.*inf];
            xdata = [0.*y(:)'+target.XLim(1);0.*y(:)'+target.XLim(2);y(:)'.*inf]; 
        end
        xdata = xdata(:); ydata = ydata(:);
        selection.Data=[xdata ydata];
        selection.Visible='on';
        %
        N=size(object.Data,1);
        label=cell(N,1);
        for n=1:N
            label{n}=sprintf('Point %d',n);
        end
        set(Selection(2),'Items',label,'ValueIndex',CurrentPoint,'Enable','on');
        set(Coordinate,'Enable','on');
        changePoint();
    end

end