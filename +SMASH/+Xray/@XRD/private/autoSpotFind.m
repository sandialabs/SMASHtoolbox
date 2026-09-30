function roi = autoSpotFind(obj, spotNum)

% downsample image to smaller than limit

sizeLim = 250;

[rSize, cSize] = size(obj.detector.image.Data);
smallR = 1:ceil(rSize/sizeLim):rSize;
smallC = 1:ceil(cSize/sizeLim):cSize;

% find maxima in downsampled image (~0.25 s for 250x250)

[rMax, cMax] = ind2sub([numel(smallR), numel(smallC)],find(...
    islocalmax2(obj.detector.image.Data(smallR,smallC), ...
    'MaxNumExtrema', spotNum)));

% correlate results back to main image

x = obj.detector.image.Grid1(smallC(cMax));
y = obj.detector.image.Grid2(smallR(rMax));
roi.Data = [x', y];

end