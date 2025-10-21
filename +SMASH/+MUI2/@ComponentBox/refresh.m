% refresh Update component positions
%
% This method updates component positions in the current and all previous
% rows.
%    refresh(object);
%
% See also ComponentBox, fit, locate
%
function refresh(object)

if isempty(object.Component)
    return
elseif ~isscalar(object)
    for k=1:numel(object)
        refresh(object(k));
    end
    return
end

% update current row
y1=0;
y2=0;
for h=object.CurrentRow
    if getappdata(h,'header')
        y1=max(y1,getappdata(h,'voffset'));
    else
        y2=max(y2,getappdata(h,'voffset'));
    end
end
y=y1+y2+object.Margin.Vertical;

for h=object.Component
    pos=h.Position;
    pos(1)=object.Margin.Horizontal+getappdata(h,'hoffset');
    if ~any(h == object.CurrentRow)
        pos(2)=y+getappdata(h,'voffset');
    elseif getappdata(h,'header')
        pos(2)=y-getappdata(h,'voffset');
    else
        pos(2)=y-y1-getappdata(h,'voffset');        
    end    
        h.Position=pos;
end

end