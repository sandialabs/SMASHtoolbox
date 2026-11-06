% hide Hide component box
%
% This method makes the component invisible.
%    hide(object);
% No changes to figure size, position, or content are made.
%
% See also ComponentBox, fitBox, locate, show
%
function hide(object)

for k=1:numel(object)
    set(object(k).Figure,'Visible','off');
end

end