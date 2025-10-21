% NORMALIZE    return Image with normalized intensity
%
% This method returns an Image object with an intensity normalized by the
% maximum value in Data. Negative, complex, inf, and NaN values are set to 
% zero.
%    >> object=normalize(object);
%
% created August, 2025 by Nathan Brown (Sandia National Laboratories)

function obj=normalize(obj)
obj.Data(obj.Data < 0 | ~isreal(obj.Data) | isnan(obj.Data) | ...
    ~isfinite(obj.Data)) = 0;
obj.Data = obj.Data / max(obj.Data(:));
obj.DataLim = 'auto';
end