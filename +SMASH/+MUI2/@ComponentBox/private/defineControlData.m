%
function defineControlData(object,target)

for h=target
    setappdata(h,'header',false);
    setappdata(h,'hoffset',0);
    setappdata(h,'voffset',0);
    setappdata(h,'row',object.RowCounter);
end

end