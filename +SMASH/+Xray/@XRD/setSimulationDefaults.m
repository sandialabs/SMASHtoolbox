% SETSIMULATIONDEFAULTS - restore default simulation settings
%
% This method restores default simulation settings
%
% Usage:
%   >> obj = setSimulationDefaults(obj)
%
% created December, 2023 by Nathan Brown (Sandia National Laboratories)
%
function obj = setSimulationDefaults(obj)

obj.simulation = struct; % delete any old stuff
obj.simulation.mosaicity = 1*ones(1,3);
obj.simulation.mosaicityDistribution = 'uniform';
obj.simulation.mosaicitySystem = 'abc';
obj.simulation.beamDivergenceDistribution = 'normal';
obj.simulation.beamDivergenceHalfAngle = 0;
obj.simulation.gaussianSpreadHalfAngle = .5;
obj.simulation.max_hkl = 10;
obj.simulation.hklType = 'limited';
obj.simulation.simulationSize = 1e4;
obj.simulation.pixelNum = 1e5;
obj.simulation.centroidThreshold = 0.5;
obj.simulation.reportThreshold = 1e-6; % relative to normalized values, even if normalizedSpotIntensity = false
obj.simulation.uniformSpotIntensity = false;
obj.simulation.current = false;
obj.simulation.faceAlpha = 1;
obj.simulation.displayInDENNIS = true;
obj.simulation.displayLabelsInDENNIS = false;
obj.simulation.normalizedSpotIntensity = true;
obj.simulation.image = -1;

end