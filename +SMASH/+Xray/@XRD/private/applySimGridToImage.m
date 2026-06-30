% applies sim grid directly do an image

function im = applySimGridToImage(obj, im)

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

end