% THRESHOLD return thresholded IMAGE object
%
% This method returns a thresholded IMAGE object. All values greater than
% or equal to the scalar threshold are set to 1 and all other values are 
% set to 0.
%   >> object=threshold(object, thresholdValue)
%
% Users can alternatively input a vector of thresholds to generate an Image
% object whose intensity takes on integers ranging from 0 to the number of 
% thresholds.
%   >> object=threshold(object, [threshold1, threshold2, ...])
%
% Users can additionally specify that the input thresholds pertain to
% normalized intensities
%   >> object=threshold(object, thresholdValue, true)
%
% created August, 2025 by Nathan Brown (Sandia National Laboratories)
%
% See also REMOVEBACKGROUND MASKSUBTRACT CCFIND CCFILTER

function obj=threshold(obj, thresholdValue, varargin)

% normalize image if requested

if nargin > 2 && varargin{1}
    obj = normalize(obj);
end

% threshold image

thresholdValue = [-inf, thresholdValue, inf];
thresholdValue = sort(thresholdValue, 'ascend');
oldData = obj.Data;
for ii = 1:numel(thresholdValue)-1
    ind = oldData >= thresholdValue(ii) & oldData < thresholdValue(ii+1);
    obj.Data(ind) = ii-1;
end
obj.DataLim = 'auto';

end