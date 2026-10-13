% adjustWidth Adjust component width
%
% This method adjusts the width of an existing component.
%    adjustWidth(object,target,pixels);
% Mandatory input "target" indicates the component to be adjusted,
% indicated by numeric index or graphical handle, following conventions of
% the lookup method.  Mandatory input "pixels" specifies the new horizontal
% width in terms of pixels.  
% 
% The left edge of the target component always remains fixed, with the
% right edge moving to right/left for widths larger/smaller than the
% existing value. Components on the same row and to the right of the target
% are automatically shifted to accomodate the new width.  
% 
% NOTE: overlaid components cannot be adjusted and are not shifted by this
% method.
%
% See also ComponentBox, lookup, overlay, remove
%
function adjustWidth(object,target,pixels)

assert(isscalar(object),...
    'ERROR: components can only be adjusted in one box at a time');

% manage input
Narg=nargin();
assert(Narg >= 3,'ERROR: insufficent input');
try
    index=lookup(object,target);
catch ME
    throwAsCaller(ME);
end

assert(isnumeric(pixels) && isscalar(pixels) && (pixels > 0),...
    'ERROR: invalid pixel width');

% adjust and shift
target=object.Component(index);
row=getappdata(target,'row');
assert(isfinite(row),'ERROR: overlaid components cannot be adjusted');

x0=target.Position(1);
shift=pixels-target.Position(3);
target.Position(3)=pixels;

for k=1:numel(object.Component)
    h=object.Component(k);
    current=getappdata(h,'row');    
    if (current ~= row) || (h.Position(1) <= x0) || (h == target) 
        continue
    end
    h.Position(1)=h.Position(1)+shift;
end

end