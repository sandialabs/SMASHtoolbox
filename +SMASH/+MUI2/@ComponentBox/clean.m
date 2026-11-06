% clean Remove invalid components
%
% This method cleans up the component box, removing any invalid handles
% from the Component and CurrentRow property.
%    clean(object);
% Clean up is automatically performed by the remove method, but may be
% needed when components are manually deleted from the box.
%
% See also ComponentBox, remove
%
function clean(object)

keep=isvalid(object.Component);
object.Component=object.Component(keep);
keep=isvalid(object.CurrentRow);
object.CurrentRow=object.CurrentRow(keep);

end