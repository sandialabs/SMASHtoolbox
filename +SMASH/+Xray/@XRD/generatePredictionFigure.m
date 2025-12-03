% GENERATEPREDICTIONFIGURE - generate 2D figure of prediction on detector
%
% This method plots the single-crystal or powder prediction on the detector
% image in a 2D figure and outputs the figure handle.
%
% Usage:
%   >> h = generatePredictionFigure(obj);
%   >> h = generatePredictionFigure(obj, XDir, YDir)
%       --> optionally specify the XDir and YDir as 'normal' or 'reverse'
%
% created August, 2024 by Nathan Brown (Sandia National Laboratories)
%
function h = generatePredictionFigure(obj, varargin)

% parse inputs

obj = generatePrediction(obj);

noImageFlag = false;
if isnumeric(obj.detector.image)
    im = SMASH.ImageAnalysis.Image(1:100, 1:100, zeros(100,100));
    noImageFlag = true;
else
    im = obj.detector.image;
end

xdir = 'normal';
ydir = 'normal';
if nargin > 1
    xdir = varargin{1};
    if nargin > 2
        ydir = varargin{2};
    end
end

% update grid to reflect spatial extent (same method as simulation)
% a couple of notes:
%   1) the total image width is actually the grid extent plus one grid
%   because each grid value corresponds to a grid center, so you have to
%   add one half-width to each side. you can see this in view(): zooming in
%   to an edge shows that the edges encompass the grid extent plus one grid
%   2) I force uniform, monotonically increasing grids upon import so I can
%   get away with linspace and don't have to interpolate

[~, ~, xdist, ydist] = computeSimulationImageDimensions(obj);
xnum = numel(im.Grid1);
ynum = numel(im.Grid2);
xwidth = 2*xdist/xnum; % this works b/c you have half a pixel on either side
ywidth = 2*ydist/ynum;
x = linspace(-xdist+xwidth/2, xdist-xwidth/2, xnum); % recall that the pixel location is the pixel center
y = linspace(-ydist+ywidth/2, ydist-ywidth/2, ynum);
im = replaceGrid(im, 'Grid1', x);
im = replaceGrid(im, 'Grid2', y);

% pull out detector and spot information
% I confirmed the spot locations two ways: I numerically confirmed them
% with a centered detector and I visually confirmed them with a noncentered
% detector by zooming in and identifying the location in the image

spotLoc = obj.prediction.spotLocations;
checkedInd = obj.externalUserData.checkedInd;
displayInd = obj.externalUserData.displayInd;
plotInd = checkedInd(2:end) & displayInd;
spotLoc = spotLoc(plotInd,:,:);

planePoints = obj.detector.planePoints;
planeCenter = obj.detector.location;
planeVecs = planePoints - planeCenter;
startPoint = planeCenter - planeVecs(1,:) - planeVecs(2,:);
planeVecs = planeVecs./vecnorm(planeVecs,2,2);
if ~isempty(spotLoc)
    x = dot(spotLoc - startPoint, ...
        repmat(planeVecs(2,:),size(spotLoc,1),1,size(spotLoc,3)),2) - ...
        xdist;
    y = dot(spotLoc - startPoint, ...
        repmat(planeVecs(1,:),size(spotLoc,1),1,size(spotLoc,3)),2) - ...
        ydist;
end

% plot and export

im.GraphicOptions.XDir = xdir;
im.GraphicOptions.YDir = ydir;
h = view(im);
axis(h.axes, 'equal');
hold(h.axes,'on');

if ~isempty(spotLoc)
    switch obj.prediction.type
        case 'single-crystal'
            plot(h.axes, x, y, 'r*', 'markersize', 5);
        case 'powder'
            plot(h.axes, permute(x,[3 1 2]), permute(y, [3 1 2]), ...
                'r-', 'LineWidth', 2)
    end
end

if noImageFlag
    colormap(h.axes, 'gray')
    caxis([-.5 .1]);
end

title(h.axes,'');
h = h.figure;

end