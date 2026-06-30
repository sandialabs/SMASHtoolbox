% FILLMISSING    Fills missing (NaN) values with MATLAB's fillmissing2
%
% Replace nan values with a 3x3 mean filter
%     >> object=fillmissing(object)
%
% Replace nan values according to the fillmissing2 inputs
%     >> object=fillmissing(object, method)
%     >> object=fillmissing(object, movemethod, window)
%     >> object=fillmissing(object, ___, Name=Value)
%
% FILLMISSING can be used in conjunction with REPLACE to selectively
% replace specific data points without having to perform a global smooth or
% interpolation. For instance, calling obj=replace(obj,nan,obj.Data<=0)
% before obj=fillmissing(obj) will fill in all zero and negative data 
% points. Calling obj=replace(obj,nan) will let the user graphically select 
% the region to be filled in.
%
% See also Image, replace, replacenan
%

%
% created June, 2026 by Nathan Brown (Sandia National Laboratories)
%
function obj=fillmissing(obj, varargin)
if nargin < 2
    varargin = {'movmean', 3};
end
obj.Data = fillmissing2(obj.Data, varargin{:});
end