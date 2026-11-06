% CALFILTER - apply Gaussian filter subtraction for detector calibration
%
% This method, inspired by PyFAI's blob detection method, applies a
% Gaussian filter to the detector image and then subtracts the image from
% the result to enable later connected component filtering.
%
% Usage:
%   >> obj = calFilter(obj)
%
% created October, 2026 by Nathan Brown (Sandia National Laboratories)
%
function obj = calFilter(obj)

%% Input handling

assert(contains(obj.calibration.type,'detector'), ...
    'Not compatible with crystal calibrations')

im = obj.detector.image;
assert(~isnumeric(im), 'No detector image')

sigma = obj.calibration.opts.gaussianSigma;
validFilterCutoff = obj.calibration.opts.validFilterCutoff;

%% Code

% set up gaussian filter kernel

filterSize = 2*ceil(2*sigma)+1; % imgaussfilt default
r = floor(filterSize/2);
[x, y] = meshgrid(-r:r,-r:r);
k = exp((-(x.^2+y.^2)/(2*sigma^2)));
k = k / sum(k(:));

% apply gaussian filter to data

filt = padarray(im.Data,[r r],'replicate','both'); % imgaussfilt default
filt = conv2(filt,k,'valid');
valid = padarray(double(im.Data > 0),[r r], 'replicate', 'both');
valid = conv2(valid,k,'valid');

filt = im - replace(im,filt,1:numel(filt));
badInd = valid < validFilterCutoff;
filt = replace(filt,0,badInd);

obj.calibration.filterSubtract = filt;

end
