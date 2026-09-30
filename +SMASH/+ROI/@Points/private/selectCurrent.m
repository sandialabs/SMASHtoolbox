function object=selectCurrent(object,target)

persistent FigureTools
if isempty(FigureTools)
    FigureTools=packtools.import('SMASH.Graphics.FigureTools.*');
end

%% display figure with existing ROI (if present)
fig=ancestor(target,'figure');
figure(fig);
selection=view(object,target);
switch object.Mode
    case 'open'
        selection.LineWidth=0;
    otherwise
        selection.LineWidth=2;
end

persistent ZoomPan
if isempty(ZoomPan)
    local=packtools.import('.*');
    ZoomPan=local.ZoomPan;
end
ZPstate=ZoomPan('state');
ZoomPan(fig,'on');

CurrentPoint=1;
width=max(selection.LineWidth,2);
scale=1.5;
highlight=line('Parent',target,...
    'Marker','o','MarkerSize',scale*selection.MarkerSize,'LineWidth',width,...
    'MarkerEdgeColor',selection.ConjugateColor,'MarkerFaceColor',selection.Color,...
    'LineStyle','none','Visible','off');

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
                temp=get(target,'CurrentPoint');
                temp=temp(1,1:2);
                bound=get(target,'XLim');
                if (temp(1) < bound(1)) || (temp(1) > bound(2))
                    return
                end
                bound=get(target,'YLim');
                if (temp(2) < bound(1)) || (temp(2) > bound(2))
                    return
                end
                data=object.Data;
                N=size(data,1);
                data(end+1,:)=temp;
                if (N > 0) && (CurrentPoint < N)
                    index=[1:CurrentPoint (CurrentPoint+2):(N+1) CurrentPoint+1];
                    data(index,:)=data;
                end
                object=define(object,data);
                if CurrentPoint < size(object.Data,1)
                    CurrentPoint=CurrentPoint+1;
                end
            case 'extend' % shift-click
                if isempty(object.Data)
                    return
                end
                pos=get(target,'CurrentPoint');
                pos=pos(1,1:2);
                L2=sum((object.Data-pos).^2,2);
                [~,index]=min(L2);
                keep=true(size(object.Data,1),1);
                keep(index)=false;
                object=define(object,object.Data(keep,:));
                if CurrentPoint > 1
                    CurrentPoint=CurrentPoint-1;
                end
            case 'alt' % control-click
                if isempty(object.Data)
                    return
                end
                pos=get(target,'CurrentPoint');
                pos=pos(1,1:2);
                L2=sum((object.Data-pos).^2,2);
                [~,index]=min(L2);
                CurrentPoint=index;
        end
        set(Selection(2),'ValueIndex',1);
        update();
    end

% create dialog
cb=SMASH.MUI2.ComponentBox();
font=struct('Name','','Size',14);
try %#ok<TRYNC>
    Q=calfont.lookup();
    font.Name=Q.Name;
    font.Size=Q.Size;    
end
setFont(cb,font.Name,font.Size);
setName(cb,'ROI settings');

Name=addEdit(cb,20);
Name(end+1)=addButton(cb,8);
set(Name(1),'Text','Name:');
set(Name(2),'Value',object.Name,'ValueChangedFcn',@changeName);
    function changeName(varargin)
        object.Name=get(Name(2),'Value');
    end
set(Name(3),'Text','Comments','ButtonPushedFcn',@changeComments);
    function changeComments(varargin)
        object=comment(object);
    end
newRow(cb);

Selection=addDropdown(cb,20);
Selection(end+1)=addButton(cb,7);
set(Selection(1),'Text','Current point:');
set(Selection(2),'ValueChangedFcn',@changePoint);
    function changePoint(varargin)
        index=get(Selection(2),'ValueIndex');
        index=min(index,size(object.Data,1));
        CurrentPoint=index;
        x=object.Data(index,1);
        temp=sprintf('%g',x);
        set(Coordinate(1),'Value',temp,'UserData',temp);
        y=object.Data(index,2);
        temp=sprintf('%g',y);
        set(Coordinate(2),'Value',temp,'UserData',temp);
        set(highlight,'XData',x,'YData',y,'Visible','on');
    end
set(Selection(3),'Text','Remove','ButtonPushedFcn',@removePoint);
    function removePoint(varargin)
        index=CurrentPoint;
        if index == 0
            return
        end
        keep=true(size(object.Data,1),1);
        keep(index)=false;
        object=define(object,object.Data(keep,:));
        CurrentPoint=min(CurrentPoint,size(object.Data,1));
        update()
    end
newRow(cb);

label=get(get(target,'XLabel'),'String');
if isempty(label)
    label='x';
end
label=[label ' :'];
h=addEdit(cb,20);
Coordinate(1)=h(end);
set(Coordinate(1),'Value',label,'ValueChangedFcn',@checkValue);
newRow(cb);

label=get(get(target,'YLabel'),'String');
if isempty(label)
    label='y';
end
label=[label ' :'];
h=addEdit(cb,20);
Coordinate(2)=h(end);
set(Coordinate(2),'Value',label,'ValueChangedFcn',@checkValue);

    function checkValue(src,~)
        in=sscanf(get(src,'Value'),'%s',1);
        set(src,'String',in);
        value=sscanf(in,'%g',1);
        if isempty(value)
            set(src,'Value',get(src,'UserData'))
        else
            set(src,'UserData',in);
            temp(1)=sscanf(get(Coordinate(1),'Value'),'%g',1);
            temp(2)=sscanf(get(Coordinate(2),'Value'),'%g',1);
            object.Data(CurrentPoint,:)=temp;
            update();
        end
    end
newRow(cb);

Button(1)=addButton(cb,10);
Button(2)=addButton(cb,10);
set(Button(1),'Text','Use mouse','ButtonPushedFcn',@useMouseButton);
set(Button(2),'Text','Help','ButtonPushedFcn',@mouseHelp);
set(cb.Figure,'KeyPressFcn',@useMouseButton);
    function useMouseButton(varargin)
        % what if the target was deleted?
        figure(fig);
    end
    function mouseHelp(varargin)
        FigureTools.focus('off');
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
            summary=sprintf('%s\n',summary{:});
            h=addTextarea(junk,40,3);
            set(h(1),'Text','Instructions:');
            set(h(2),'Value',summary,'ValueChangedFcn'...
                ,@(src,~) set(src,'Value',summary));
            fit(junk);
            locate(junk,'center',cb.Figure);
            show(junk);
            junk.Figure.Tag='PointsSelectHelp';
            FigureTools.focus([new cb.Figure fig]);
        else
            figure(new);
        end
    end
newRow(cb);

Button(3)=addButton(cb,10);
set(Button(3),'Text','Done','ButtonPushedFcn',@doneButton);
    function doneButton(varargin)
        delete(cb);
        h=findall(groot,'Type','figure','Tag','PointsSelectHelp');
        delete(h);
    end
set(cb.Figure,'DeleteFcn',@doneButton);

%% show dialog
update()

fit(cb);
locate(cb,'center',fig);
show(cb);

FigureTools.focus([cb.Figure fig]);
waitfor(cb.Figure);
FigureTools.focus('off');

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
        switch object.Mode
            case {'closed' 'convex'}
                data(end+1,:)=data(1,:);
        end
        selection.Data=data;
        selection.Visible='on';
        %
        N=size(object.Data,1);
        label=cell(N,1);
        for n=1:N
            label{n}=sprintf('Point %d',n);
        end
        CurrentPoint=max(CurrentPoint,1);
        CurrentPoint=min(CurrentPoint,numel(label));
        set(Selection(2),'Items',label,'ValueIndex',CurrentPoint,'Enable','on');
        set(Coordinate,'Enable','on');
        changePoint();
    end

end