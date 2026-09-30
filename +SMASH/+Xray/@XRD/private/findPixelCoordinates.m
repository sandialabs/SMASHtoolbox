function [gCoords, qCoords, cCoords] = findPixelCoordinates(obj, varargin)

% output pages are xyz
% cCoords cell in order of top left, top right, bottom right, bottom left

% parse inputs

qPoints = 'none';
cornerFlag = false;
if nargin > 1
    qPoints = varargin{1}; % [pt, xy, reg]
end
if nargin > 2
    cornerFlag = varargin{2};
end

% pull out needed variables (and cast to appropriate dimensions)

planePoints = reshape(obj.detector.planePoints, 2, 1, 3);
planeCenter = reshape(obj.detector.location, 1, 1, 3);
grid1 = obj.detector.image.Grid1;
grid2 = obj.detector.image.Grid2;
ydir = 1;
if strcmp(obj.detector.image.GraphicOptions.YDir, 'reverse')
    ydir = -1;
end

% determine coordinates of each pixel (have to do manually b/c I use
% texturemap to plot and matlab won't give me the pixel locations)

% I force monotonically uniformly increasing grids during import. The grid
% values start at the bottom left for a 'normal' YDir and at the top left
% for a 'reverse' YDir. The code was originally written for 'normal' and
% then adapted to handle 'reverse' by pointing h_vec in the opposite
% direction

% define grid vectors and starting point

h_vec = ydir*(planePoints(1,:,:) - planeCenter);
w_vec = planePoints(2,:,:) - planeCenter;
startPoint = planeCenter - h_vec - w_vec;

% find grid boundaries for normalization, accounting for the fact that
% the pixel locations should be at the grid box centers and that the vector
% tips and tails are at grid box edges

boxBounds1 = [1.5*grid1(1) - 0.5*grid1(2), 1.5*grid1(end) - 0.5*grid1(end-1)];
boxBounds2 = [1.5*grid2(1) - 0.5*grid2(2), 1.5*grid2(end) - 0.5*grid2(end-1)];

% compute grid coordinates

[grid1Mat, grid2Mat] = meshgrid(grid1, grid2);
gCoords = 'none';
if ~cornerFlag
    gCoords = computeCoords(grid1Mat, grid2Mat, boxBounds1, boxBounds2, ...
        startPoint, h_vec, w_vec); % [r c xyz]
end

% compute query point coordinates

qCoords = 'none';
if isnumeric(qPoints)
    qPoints = permute(qPoints, [1 3 2]); % [pt reg xy] (so I can input 2D array)
    qCoords = computeCoords(qPoints(:,:,1), qPoints(:,:,2), ...
        boxBounds1, boxBounds2, startPoint, h_vec, w_vec); % [pt reg xyz]
end

% compute grid corner coordinates (generally faster to iterate through a
% cell than to manipulate one large matrix on the back end).

cCoords = 'none';
if cornerFlag
    g1diff = (grid1(2) - grid1(1))/2;
    g2diff = (grid2(2) - grid2(1))/2;
    cCoords = cell(1,4);
    g1Seq = [-1 +1 +1 -1]; % TL, TR, BR, BL
    g2Seq = [+1 +1 -1 -1];
    for ii = 1:4
        cCoords{ii} = computeCoords(grid1Mat + g1Seq(ii)*g1diff, ...
            grid2Mat + g2Seq(ii)*g2diff, boxBounds1, boxBounds2, ...
            startPoint, h_vec, w_vec);
    end
end

end

function coords = computeCoords(x, y, boxBounds1, boxBounds2, ...
    startPoint, h_vec, w_vec)
x = (x - boxBounds1(1))/(boxBounds1(2) - boxBounds1(1));
y = (y - boxBounds2(1))/(boxBounds2(2) - boxBounds2(1));
coords = startPoint + y.*(2*h_vec) + x.*(2*w_vec);
end