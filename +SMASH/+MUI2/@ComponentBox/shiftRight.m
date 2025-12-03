% shiftRight Shift component(s) to the right side
%
% This method shifts the right side of a target component.
%    shiftRight(object,target,reference);
% Optional input "target" indicates the component(s) to be shifted,
% defaulting to the most recently created component.  Optional input
% "reference" defines the right edge position via one or more components,
% defaulting to all existing components.  Both inputs can use explicit
% graphic handles or integer indexing as described in the lookup method. 
% 
% Shifted component widths remain the same, moving horizontally so that the
% *rightmost* side aligns with the reference edge.  Components shifted at
% the same time retain the same horizontal spacing.
%
% See also ComponentBox, lookup, stretchRight
%
function shiftRight(object,target,reference)

assert(~isempty(object.Component),'ERROR: no components added yet');

% manage input
Narg=nargin();
if (Narg < 2) || isempty(target)
    target=object.Component(end);
else
    try
        [~,target]=lookup(object,target);
    catch ME
        throwAsCaller(ME);
    end        
end

if (Narg < 3) || isempty(reference)
    reference=object.Component;
else
     try
        [~,reference]=lookup(object,reference);
    catch ME
        throwAsCaller(ME);
    end    
end
 
% determine and apply right edge
right=0;
for n=1:numel(reference)
    pos=get(reference(n),'Position');
    right=max(right,pos(1)+pos(3));
end

shift=inf();
for n=1:numel(target)
    pos=get(target(n),'Position');
    shift=min(shift,right-pos(1)-pos(3));
end

for n=1:numel(target)
    pos=get(target(n),'Position');
    pos(1)=pos(1)+shift;
    set(target(n),'Position',pos);
    setappdata(target(n),'hoffset',pos(1)-object.Gap.Horizontal);
end

end