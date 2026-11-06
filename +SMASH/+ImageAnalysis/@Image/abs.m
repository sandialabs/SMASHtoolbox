% ABS return Image absolute value
%
% This method returns the absolute value of an Image object
%    >> object=abs(object);
%
% created August, 2025 by Nathan Brown (Sandia National Laboratories)

function obj=abs(obj)
obj.Data = abs(obj.Data);
end