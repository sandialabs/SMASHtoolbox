% REPLACENAN    replaces NaN values with 0
%
% This method replaces NaN values with 0
%     >> object=replacenan(object)
%
% See also Image
%

%
% created August, 2025 by Nathan Brown (Sandia National Laboratories)
%
function obj=replacenan(obj)
obj.Data(isnan(obj.Data)) = 0;
end