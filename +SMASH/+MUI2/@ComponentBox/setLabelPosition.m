% setLabelPosition Set block label position
%
% This methods sets the label position for composite blocks, such as
% addEdit.
%    setLabelPosition(object,value);
% Optional input "value" can be 'above' (default) or 'left'.
%
% See also ComponentBox, addEdit
%
function setLabelPosition(object,value)

Narg=nargin();
if (Narg < 2) || isempty(value)
    value='above';
end

valid={'above' 'left'};
assert(any(strcmpi(value,valid)),...
    'ERROR: label position must be ''%s'' or ''%s''',valid{:});

for k=1:numel(object)
    object(k).LabelPosition=lower(value);
end

end