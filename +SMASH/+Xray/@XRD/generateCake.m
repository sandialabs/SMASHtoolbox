% Under construction
%
function [obj, h, im] = generateCake(obj, varargin)

% check that we have something to compute

assert(isa(obj.detector.image, 'SMASH.ImageAnalysis.Image'), ...
    'No detector image!');

% parse inputs 

makeImage = true;
twoThetaRes = 0.2;
chiRes = 0.2;
rotAng = nan;
viewImage = true;
if nargin > 1 && isnumeric(varargin{1})
    twoThetaRes = varargin{1};
elseif nargin > 1 && islogical(varargin{1})
    makeImage = varargin{1};
elseif nargin > 1
    error('Invalid input');
end
if nargin > 2
    chiRes = varargin{2};
end
if nargin > 3
    rotAng = varargin{3};
end
if nargin > 4
    viewImage = varargin{4};
end

% pull out needed variables

obj = findStraightThruLocation(obj, true);
coords = findPixelCoordinates(obj);
cdata = obj.detector.image.Data;
crystalCenter = obj.crystal.location;
s0 = obj.source.s0/vecnorm(obj.source.s0,2,2);
straightThru = obj.prediction.straightThruLocation;

% determine the chi reference vector the same way it's done in
% generatePrediction

if s0(3) == 0
    a = [0 0 1];
else
    a = [1 1 -(s0(1)+s0(2))/s0(3)];
end

% apply rotation to chi reference vector per user input

if ~isnan(rotAng)
    a = a*cosd(rotAng) + cross(s0,a)*sind(rotAng) + ...
        s0*dot(s0,a)*(1-cosd(rotAng));
end
a = a/norm(a);

% recast and explicitly expand where necessary

crystalCenter = reshape(crystalCenter,1,1,3);
straightThru = reshape(straightThru,1,1,3);
s0 = repmat(reshape(s0,1,1,3), size(cdata,1), size(cdata,2));
a = repmat(reshape(a,1,1,3), size(cdata,1), size(cdata,2));

% compute theta and chi

v = coords - crystalCenter;
twoTheta = acosd(dot(v,s0,3) ./ vecnorm(v,2,3)); % s0 and v are 1

v = coords - straightThru;
chi = atan2d(dot(s0,cross(v,a,3),3), dot(v,a,3)); % signing based on rotation about s0

% store values in results

obj.results.cake.intensity = cdata;
obj.results.cake.twoTheta = twoTheta;
obj.results.cake.chi = chi;

h = -1;
im = -1;
if makeImage

    % generate figure

    % I use a combined bin to efficiently handle 2D indexing. The idea is
    % that the linear index corresponds to the correct subscript. Example:
    % in a 3x3 image, index 6 needs to correspond to binY of 3 and binX of
    % 2. This is accomplished by binY + (binX-1)*numel(x) = 3+(2-1)*3 = 6

    twoThetaEdge = 0:twoThetaRes:180; chiEdge = -180:chiRes:180;
    twoThetaEdge(end) = 180; chiEdge(end) = 180;
    [~, edgeX, edgeY, binX, binY] = histcounts2(twoTheta, chi, ...
        twoThetaEdge, chiEdge);
    x = edgeX(1:end-1) + diff(edgeX)/2;
    y = edgeY(1:end-1) + diff(edgeY)/2;
    dat = zeros(numel(y), numel(x));
    bin = binY + (binX-1)*numel(y); % combined bin to handle 2D
    dat(1:max(bin(:))) = accumarray(bin(:), cdata(:));
    im = SMASH.ImageAnalysis.Image(x, y, dat);

    % figure details

    im.GraphicOptions.ColorMap = 'parula';
    im.DataLabel = 'Intensity';
    if any(dat(:))
        xlims = x([find(any(dat,1),1,'first'), ...
            find(any(dat,1),1,'last')]) + [-1 1]*twoThetaRes;
        ylims = y([find(any(dat,2),1,'first'), ...
            find(any(dat,2),1,'last')]) + [-1 1]*chiRes;
        im = limit(im,xlims,ylims);
    end
    im.Grid1Label = '2θ (deg)';
    im.Grid2Label = 'χ (deg)';
    im.Name = 'Cake Plot';
    im.GraphicOptions.Title = im.Name;

    % show figure

    if viewImage
        h = view(im);
        h = h.figure;
    end
    
end

end