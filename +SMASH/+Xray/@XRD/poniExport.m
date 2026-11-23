% PONIEXPORT - export a poni calibration file for pyFAI/DIOPTAS
%
% This method exports a poni file for direct loading into pyFAI or DIOPTAS.
% It also outputs a parameter structure containing the information written
% to the file.
%
% Usage:
%   >> params = poniImport(obj)
%   >> params = poniImport(obj, poniFile, conv)
%       -> poniFile is the name of the poni file (default is SMASHcal.poni)
%       -> conv is the ratio of the obj unit to meters (default is 1e-3)
%
% created November, 2026 by Nathan Brown (Sandia National Laboratories)
%
function params = poniExport(obj, varargin)

% input parsing

assert(isa(obj.detector.image,'SMASH.ImageAnalysis.Image'), ...
    'No detector image!')
params.flipFlag = false;
if strcmp(obj.detector.image.GraphicOptions.YDir, 'normal')
    warning(['The detector Y-direction is opposite of the DIOPTAS convention - ', ...
        'The image will need to be flipped in DIOPTAS']);
    params.flipFlag = true;
end
poniFile = 'SMASHcal.poni';
conv = 1e-3; % DENNIS assumes mm
if nargin > 1
    poniFile = varargin{1};
    if ~contains(poniFile,'.poni')
        poniFile = [poniFile, '.poni'];
    end
    if nargin > 2
        conv = varargin{2};
    end
end

% recast geometry for poni calculations: crystal at origin and x-ray along
% +y and then assume z is up and down

obj = recastGeometry(obj);

% rotate the detector so that it is perpendicular to the y-axis and sits at 
% a postive y value to compute the rotation values (rotates right-handed in
% x and then z so that results are left-handed for z and then x).

[params.Rot2, params.Rot1, vecs] = alignPlaneToPositiveY(...
    [obj.detector.location; obj.detector.planePoints]);
params.Rot3 = 0; % not needed
obj.detector.location = vecs(1,:);
obj.detector.planePoints = vecs(2:3,:);

% compute the translations of the perpendicular detector

sz = obj.detector.size / 2;
params.Distance = conv*obj.detector.location(2);
params.Poni1 = conv*(sz(1) - obj.detector.location(3));
params.Poni2 = conv*(sz(2) - obj.detector.location(1));

% perform other calculations

params.Wavelength = obj.source.lambda*1e-10;
params.nRows = numel(obj.detector.image.Grid2);
params.nCols = numel(obj.detector.image.Grid1);
params.pixel1 = conv*obj.detector.size(1)/params.nRows;
params.pixel2 = conv*obj.detector.size(2)/params.nCols;

% write the file

writePoni(params, poniFile);

end

%% geometry reset
function obj = recastGeometry(obj)
obj = changeObject(obj, 'detector', 'location', ...
    obj.detector.location - obj.crystal.location);
obj = changeObject(obj, 'source', 'location', ...
    obj.source.location - obj.crystal.location);
obj = changeObject(obj, 'crystal', 'location', [0 0 0]);

target = [0 1 0];
init = obj.source.s0;
ang = real(acosd(dot(init,target)/(norm(init)*norm(target)))); % sometimes get small complex numbers so have to take real
if abs(ang) < 1e-6 || abs(ang-180) < 1e-6
    if init(3) == 0
        rotVec = [0 0 1];
    else
        rotVec = [1 1 (-init(1)-init(2))/init(3)];
    end
else
    rotVec = cross(init,target);
end
obj = changeObject(obj, 'source', 'rotate', ang, true, rotVec);
end

%% detector rotation
function [thetaX, thetaZ, Prot] = alignPlaneToPositiveY(P)

% RH rotations about x and then z to make the plane normal to y with a +y
% value

v1 = P(2,:) - P(1,:);
v2 = P(3,:) - P(1,:);
n = cross(v1, v2)';
n = n / norm(n);

% the plane equation is n'*p = d. After an origin-centered rotation,
% its y-coordinate will have magnitude abs(d).

d = dot(n, P(1,:)');
scale = norm(P, 'fro');
if abs(d) <= 1e-12 * scale
    error(['The plane passes through or is too close to the origin; ' ...
        'rotations about the origin cannot place it at positive y.']);
end

% first eliminate the normal's z component

thetaX = atan2(-n(3), n(2));

cx = cos(thetaX);
sx = sin(thetaX);
Rx = [1   0    0;
    0  cx  -sx;
    0  sx   cx];

nAfterX = Rx * n;

% this z rotation initially points the normal along +y

thetaZ = atan2(nAfterX(1), nAfterX(2));

% if d is negative, point the normal along -y instead. This makes
% the plane itself lie at positive y: nRot'*pRot = d

if d < 0
    thetaZ = thetaZ + pi;
end

cz = cos(thetaZ);
sz = sin(thetaZ);
Rz = [cz  -sz  0;
    sz   cz  0;
    0    0  1];

Prot = (Rz * Rx * P')';

end

%% poni writing
function writePoni(params, poniFile)
fid = fopen(char(poniFile),'w');
if params.flipFlag
    fprintf(fid, ['# WARNING: This calibration was written for a', ...
        ' flipped image. The user must flip the image in DIOPTAS to use', ...
        ' this poni file\n']);
end
fprintf(fid, 'poni_version: 2\n');
fprintf(fid, 'Detector: Detector\n');
fprintf(fid, ['Detector_config: {"pixel1": %.16g, ' ...
    '"pixel2": %.16g, "max_shape": [%d, %d]}\n'], ...
    params.pixel1, params.pixel2, params.nRows, params.nCols);
fprintf(fid, 'Distance: %.16g\n', params.Distance);
fprintf(fid, 'Poni1: %.16g\n', params.Poni1);
fprintf(fid, 'Poni2: %.16g\n', params.Poni2);
fprintf(fid, 'Rot1: %.16g\n', params.Rot1);
fprintf(fid, 'Rot2: %.16g\n', params.Rot2);
fprintf(fid, 'Rot3: %.16g\n', params.Rot3);
fprintf(fid, 'Wavelength: %.16g\n', params.Wavelength);
fclose(fid);
end