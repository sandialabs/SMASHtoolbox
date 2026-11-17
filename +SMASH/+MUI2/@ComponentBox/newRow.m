% newRow Start new block row
%
% This method starts a new block row.
%    newRow(object);
% The next block added will be placed at the lower-left margin, pushing
% previous rows upward as needed.
%
% See also ComponentBox
% 
function newRow(object)

if isempty(object.CurrentRow)
    return
elseif ~isscalar(object)
    for k=1:numel(object)
        newRow(object(k));
    end
    return
end

for h=object.Component
    y=h.Position(2)-object.Margin.Vertical+object.Gap.Vertical;
    setappdata(h,'voffset',y);
end
object.CurrentRow=[];
object.RowCounter=object.RowCounter+1;

end