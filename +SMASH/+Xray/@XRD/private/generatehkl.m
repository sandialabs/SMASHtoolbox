% GENERATEHKL - generate hkl values
%
% This method generates hkl values needed for generating predicted patterns
%
% Usage:
%   >> obj = generatehkl(obj)
%   >> obj = generatehkl(obj, 'simulation')
%
% created October, 2023 by Nathan Brown (Sandia National Laboratories)
%
function obj = generatehkl(obj, varargin)

simFlag = false;
if nargin > 1 && strcmpi(varargin{1}(1), 's')
    simFlag = true;
end

if simFlag
    maxhkl = obj.simulation.max_hkl;
else
    maxhkl = obj.prediction.max_hkl;
    obj = deletePredictionAndResults(obj, 'p');
end

if ~simFlag || strcmp(obj.simulation.hklType, 'all')

    % all possible hkl values

    maxhkl = floor(maxhkl);
    n = 2*maxhkl+1;
    seed = -maxhkl:maxhkl;
    
    hkl_1 = seed.*ones(n^2,n);
    hkl_2 = repmat(seed,1,n).*ones(n,n^2);
    hkl_3 = repmat(seed,1,n^2);
    hkl = [hkl_1(:), hkl_2(:), hkl_3(:)];
    hkl(~any(hkl,2),:) = []; % remove trivial (0,0,0)

elseif strcmp(obj.simulation.hklType, 'limited')

    % only hkl values that can hit nonzero parts of the detector

    lambdaRange = extractLambdaRange(obj);

    obj1 = deleteSimulation(obj);
    obj1 = changeObject(obj1, 'prediction', 'max_hkl', obj.simulation.max_hkl);
    obj1 = changeObject(obj1, 'prediction', 'type', 'powder');
    obj1 = changeObject(obj1, 'prediction', 'option', 'separate');
    obj1 = changeObject(obj1, 'source', 'lambda', min(lambdaRange));
    obj2 = changeObject(obj1, 'source', 'lambda', max(lambdaRange));

    obj1 = generatePrediction(obj1);
    obj2 = generatePrediction(obj2);
    hkl = unique([obj1.prediction.hkl; obj2.prediction.hkl], 'rows');

else % do nothing

    return

end

if simFlag
    obj.simulation.hkl = hkl;
else
    obj.prediction.hkl = hkl;
end

end