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

obj.match.image.target = obj.detector.image;
obj.match.image.roi = [];
obj.match.image.absoluteIntensity = [];
obj.match.image.relativeIntensity = [];
obj.match.image.rank = [];
obj.match.image.weightMultiplier = [];
obj.match.image.weight = [];
obj.match.image.solution = struct('orientation', [], ...
    'mosaicity', [], ...
    'gaussianSpreadHalfAngle', [], ...
    'volumeRatio', [], ...
    'image', []);
obj.match.image.solutionInfo = struct('fval', [], 'exitflag', [], ...
    'output', []);

end