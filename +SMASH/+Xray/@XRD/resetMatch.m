% under construction
%
function obj = resetMatch(obj, varargin)

if nargin < 2 || strcmpi(varargin{1}, 'c')
    obj.match.centroids.roi = [];
    obj.match.centroids.cc = [];
    obj.match.centroids.poi = [];
    obj.match.centroids.poiIntensity = [];
    obj.match.centroids.poiExclude = [];
    obj.match.centroids.solution = struct('orientation', [], ...
        'mosaicity', [], 'image', []);
    obj.match.centroids.solutionInfo = struct('fval', [], 'exitflag', [], ...
        'output', []);
end

obj.match.spots.target = obj.detector.image;
obj.match.spots.roi = [];
obj.match.spots.absoluteIntensity = [];
obj.match.spots.relativeIntensity = [];
obj.match.spots.rank = [];
obj.match.spots.weightMultiplier = [];
obj.match.spots.weight = [];
obj.match.spots.solution = struct('orientation', [], ...
    'mosaicity', [], ...
    'gaussianSpreadHalfAngle', [], ...
    'volumeRatio', [], ...
    'image', []);
obj.match.spots.solutionInfo = struct('fval', [], 'exitflag', [], ...
    'output', []);

obj.match.rings.expLineouts = [];
obj.match.rings.solution = struct('orientation', [], ...
    'mosaicity', [], ...
    'image', [], ...
    'simLineouts', []);
obj.match.rings.solutionInfo = struct('fval', [], 'exitflag', [], ...
    'output', []);

end