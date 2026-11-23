function [xnum, ynum, xdist, ydist] = computeSimulationImageDimensions(obj)

% I broke this into a separate function to avoid having to repeat code when
% determining the detector image size required for comparison to
% simulations

planePoints = obj.detector.planePoints;
planeLoc = obj.detector.location;
detectorPoints = obj.simulation.pixelNum;

ydist = norm(planePoints(1,:) - planeLoc);
xdist = norm(planePoints(2,:) - planeLoc);
ratio = xdist/ydist;
xnum = round(sqrt(ratio*detectorPoints));
ynum = round(detectorPoints/sqrt(ratio*detectorPoints));

end