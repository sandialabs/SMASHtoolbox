% stretchRight Stretch component from the right side
%
% This method stretches the right side of a UI component.
%    stretchRight(object,target,reference);
% Optional input "target" indicates the component to be stretched,
% defaulting to the most recently created component.  Optional input
% "reference" defines the right edge position by one or more components,
% defaulting to all existing components.  Both inputs can use explicit
% graphic handles or integer indexing as described in the lookup method.
% 
% The left side of stretched component remains fixed while the right
% side is moved to the reference edge.  All components on the same row and
% to the right are automatically shifted by stretched component's width
% change.
%
% See also ComponentBox, lookup, shiftRight
%
function stretchRight(object,target,reference)

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
    assert(isscalar(target),...
        'ERROR: components must be stretched one at a time');
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
 
% determine right edge
right=0;
for n=1:numel(reference)
    pos=get(reference(n),'Position');
    right=max(right,pos(1)+pos(3));
end

% stretch component and shift row items as needed
width=right-target.Position(1);
assert(width >= 1,'ERROR: components cannot be stretched below 1 pixel');
shift=width-target.Position(3);
target.Position(3)=width;

x0=target.Position(1);
row=getappdata(target,'row');
for k=1:numel(object.Component)
    h=object.Component(k);
    current=getappdata(h,'row');    
    if (current ~= row) || (h.Position(1) <= x0) || (h == target) 
        continue
    end
    h.Position(1)=h.Position(1)+shift;
    setappdata(h,'hoffset',h.Position(1)-object.Gap.Horizontal);
end

end