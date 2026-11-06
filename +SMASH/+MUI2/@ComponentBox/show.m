% show Show component box
%
% This method makes the component box visible.
%    show(object);
% No changes to figure size, position, or content are made.
%
% See also ComponentBox, fit, hide, locate
%
function show(object)

for k=1:numel(object)
    figure(object(k).Figure);
end

end