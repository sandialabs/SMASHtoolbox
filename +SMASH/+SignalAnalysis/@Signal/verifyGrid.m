% verifyGrid validate Signal grid and check direction/uniformity
%
% This method verifies that the Grid array increases/decreases
% monotonically and checks uniformity.
%    object=verifyGrid(object); 
% Increasing grids are labeled with a GridDirection of "normal", while
% decreasing grids are labeled as "reverse".  Grid spacing variation
% (relative to the mean value) below the GridTolerance property are
% considered uniform
% 
% See also Signal
%
function [object,dxmean]=verifyGrid(object)

% determine direction
x=object.Grid;
dx=diff(x);
if all(dx >= 0)
    object.GridDirection='normal';
elseif all(dx <= 0)
    object.GridDirection='reverse';
else
    error('ERROR: non-monotonic Grid detected');
end

% eliminate repeated points
if any(dx == 0)
    [x,index]=unique(x); 
    warning('Eliminating repeated grid points');
    object.Grid=x;
    object.Data=object.Data(index);
end

% analyze spacing
span=abs(x(end)-x(1));
dxmean=span/(numel(x)-1);
err=abs(abs(dx)/dxmean-1);
if all(err <= object.GridTolerance)
    object.GridUniform=true;
else
    object.GridUniform=false;
end
object.GridSpacing=dxmean;

end