% fit Fit figure to components
%
% This method adjust the component box figure to fit everything contained
% within.
%    fit(object);
% Figure width and height are capped at 90% of the smallest display.
% Scrolling is automatically enabled if the component box exceeds that
% size.
%
% See also ComponentBox, hide, locate, scroll, show
%
function varargout=fit(object)

assert(all(isvalid(object)),'ERROR: box has been deleted');

monpos=get(groot(),'MonitorPositions');
Lx=0.90*min(monpos(:,3));
Ly=0.90*min(monpos(:,4));

M=numel(object);
actual=nan(M,2);

for m=1:M
    width=0;
    height=0;
    children=get(object(m).Figure,'Children');
    for n=1:numel(children)
        h=children(n);
        try            
            pos=get(h,'OuterPosition');
        catch
            continue
        end
        width=max(width,pos(1)+pos(3));
        height=max(height,pos(2)+pos(4));
    end
    if (width == 0) || (height == 0)
        return
    end
    pos=get(object(m).Figure,'Position');
    pos(3)=width+object(m).Margin.Horizontal;
    pos(4)=height+object(m).Margin.Vertical;
    actual(m,:)=pos(3:4);
    if (pos(3) > Lx) || (pos(4) > Ly)
        scroll(object(m),'on');
    else
        scroll(object(m),'off');
    end
    pos(3)=min(pos(3),Lx);
    pos(4)=min(pos(4),Ly);
    set(object(m).Figure,'Position',pos);    
end

if nargout() > 0
    varargout{1}=actual;
end

end