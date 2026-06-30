% REPLACEINF replace +/- inf values with max and min signal values
%
% This method replaces +/- inf values with the max and min signal values
% (determined in their absence). The method was originally written for
% scopes that output inf instead of peak values when signals are clipped
%   - [object, flag] = replaceInf(object)
%       -flag is 0 if no replacements, 1 if some replacements, -1 if all
%        values in the signal are inf
%
% See also Signal
%

%
% created June, 2026 by Nathan Brown (Sandia National Laboratories)
%
function [object,flag]=replaceInf(object)
pInf = object.Data == inf;
nInf = object.Data == -inf;
comb = pInf | nInf;
flag = 0;
if all(comb)
    flag = -1;
    warning('Entire signal is inf')
elseif any(comb)
    flag = 1;
end
if flag == 1
    maxVal = max(object.Data(~comb));
    minVal = min(object.Data(~comb));
    object.Data(pInf) = maxVal;
    object.Data(nInf) = minVal;
end
end