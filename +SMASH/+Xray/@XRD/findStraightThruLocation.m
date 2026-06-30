% FINDSTRAIGHTTHRULOCATION - find where x-ray beam intersects the detector
%
% This method finds where the x-ray beam intersects the detector
%
% Usage:
%   >> obj = findStraightThruLocation(obj)
%   >> obj = findStraightThruLocation(obj, true)
%       -> Returns the straight-through even if it doesn't hit the detector
%
% created May, 2023 by Nathan Brown (Sandia National Laboratories)
%
function obj = findStraightThruLocation(obj, varargin)

% extract what you need from the object

crystalLoc = obj.crystal.location;
planeLoc = obj.detector.location;
s0 = obj.source.s0;
s0 = s0/norm(s0);

% find straight thru beam location

[planeNormal, dist, n] = computePlaneValues(obj);
[spotLoc, badInd] = findIntersection(s0, planeNormal, ...
    planeLoc, crystalLoc, dist, n, -1);
if nargin < 2 || ~varargin{1}
    spotLoc(badInd,:) = [];
end
obj.prediction.straightThruLocation = spotLoc;

end
