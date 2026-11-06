function hoffset=checkCurrentRow(object)

if isempty(object.CurrentRow)
    hoffset=0;
else
    %pos=get(object.CurrentRow(end),'Position');
    pos=get(object.CurrentRow(end),'OuterPosition');
    hoffset=sum(pos([1 3]))+object.Gap.Horizontal;
end

end