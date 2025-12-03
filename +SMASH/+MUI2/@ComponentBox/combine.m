% combine Combine components with resizable panel
%
% This method combines components from the current box with a resizable
% panel in a new figure.  Components are placed in a fixed-size panel on
% the left side of this figure, with the resizable panel on the right.
%    [parent,new,fig]=combine(object);
% Output "parent" is a two-element handle array of uipanels [left right] as
% described above.  Output "new" contains graphic handles for  all
% components copied to the left panel.  Output "fig" is the graphic handle
% for the created figure, which spans the central 90% of the primary
% display.
%
% When an object array is passed to this method, components from each box
% are copied into separate tabs in the left panel.  In this case, the
% output "new" is a cell array with one element per box.  An additional
% output:
%    [parent,new,fig,tg]=combine(object);
% returns the graphic handle for the tab group.  Otherwise, the behavior of
% this method is the same for one component box or an object array.
% 
% The right panel automatically resizes with the figure subject to a
% minimum width and height.  These minimum dimensions are defined in terms
% of the primary display size and can be explicitly controlled.
%    [...]=combine(object,minsize);
% Optional input "minsize" can be a scalar (common to each direction) or a
% two-element array [horizontal vertical]; the default value is 0.25.
% Scrolling is automatically enabled when the figure is too small to
% support the component panel on the left and the minimum right panel.
% There is no requirement that the right panel be smaller than the display.
%
% The figure method is made visible by default.  That behavior can be
% suppressed with an additional input.
%    [...]=combine(object,minsize,'hide'); 
% This feature allows additional graphics to be added before the end user
% sees the figure.
% 
% NOTE: component actions should be finalized *after* being combined, not
% before. While most original component settings transfer to the copied
% objects, callback references to the former may not function correctly.
%
% See also ComponentBox, copy
%
function [parent,new,fig,tg]=combine(object,minsize,mode)

% manage input
Narg=nargin();

if (Narg < 2) || isempty(minsize)
    minsize=repmat(0.25,[1 2]);
else
    assert(isnumeric(minsize) && all(minsize > 0),...
        'ERROR: invalid minimum size');
    if isscalar(minsize)
        minsize=repmat(minsize,[1 2]);
    end
    minsize=minsize(1:2);
end

if (Narg < 3) || isempty(mode) || strcmpi(mode,'show')
    show=true();
elseif strcmpi(mode,'hide')
    show=false();
else
    error('ERROR: mode must be ''show'' or ''hide''');
end

% create component panel
fig=SMASH.MUI2.Figure('AutoResizeChildren','off','Visible','off',...'
    'Name','Combined component box',...
    'Units','normalized','Position',[0.10 0.10 0.80 0.80]);
fig=fig.Handle;
movegui(fig,'center');
fig.Units='pixels';
figpos=fig.Position;

if isscalar(object)
    [parent,new]=copy(object,fig,'fit');
else
    N=numel(object);    
    new=cell(1,N);
    tg=uitabgroup(fig,'AutoResizeChildren','off');      
    Lx=0;
    Ly=0;
    for k=1:N                
        t=uitab(tg,'Title',sprintf('Box %d',k),'AutoResizeChildren','off');  
        if k == 1
            while true
                delta=tg.OuterPosition-tg.InnerPosition;
                if all(delta(3:4) > 0)
                    break
                end
                pause(0.01);
            end            
        end        
        [~,new{k}]=copy(object(k),t,'fit');
        if Lx > tg.OuterPosition(3)
            tg.OuterPosition(3)=Lx;
            tg.Parent.OuterPosition(3)=Lx;
        else
            Lx=tg.OuterPosition(3);
        end
        if Ly > tg.OuterPosition(4)
            tg.OuterPosition(4)=Ly;
            t.Parent.OuterPosition(4)=Ly;
        else
            Ly=tg.OuterPosition(4);
        end
    end
    parent=uipanel(fig,'AutoResizeChildren','off','BorderType','none',...
        'Position',tg.Position);
    tg.Parent=parent;
    tg.Position(1:2)=1;
    for k=1:N
        h=new{k}(1).Parent;
        h.Position(1)=1;
        h.Position(2)=tg.InnerPosition(4)-h.Position(4);        
    end
end

% create resizable panel
parent(2)=uipanel(fig,'AutoResizeChildren','off','BorderType','none');

pos1=getpixelposition(parent(1));
Lx1=pos1(3);
Ly1=pos1(4);
pos2=getpixelposition(parent(2));
ss=get(groot(),'ScreenSize');
Lx2=minsize(1)*ss(3);
Ly2=minsize(2)*ss(4);
updateFigure();
set(fig,'SizeChangedFcn',@updateFigure);
    function updateFigure(varargin)
        pos0=getpixelposition(fig);
        Ly=max([pos0(4) Lx1 Ly1]);
        pos1(1)=1;
        pos1(2)=max(Ly-Ly1,0);
        setpixelposition(parent(1),pos1);              
        pos2(1)=Lx1;
        pos2(3)=max(Lx2,pos0(3)-pos2(1));
        pos2(3)=max(pos2(3),Lx1);
        pos2(4)=max(Ly2,pos0(4));       
        pos2(4)=max(pos2(4),Ly1);
        pos2(2)=max(Ly-pos2(4),0);        
        setpixelposition(parent(2),pos2);        
    end

parent(1).Tag='LeftPanel';
parent(2).Tag='RightPanel';
set(fig,'Position',figpos,'Scrollable','on')
if show
    figure(fig);
end

end
