% iteratively background and cc filter at each roi point to find the
% associated cc region

function cc = findCC(im, roi, thresh, filterBounds, type, varargin)
regSize = numel(im.Data)/2e5;
if ~isempty(varargin)
    regSize = varargin{1};
end
if isnumeric(filterBounds) % not default cal behavior
    objAlt = processImage(obj, 'bandpassfilter', filterBounds, 'gaussian');
    im = objAlt.detector.image;
end
cc = iterativeCCFilter(im, roi, thresh, regSize, type);
end

function cc = iterativeCCFilter(im, roi, thresh, regSize, type)

% prelim setup

cc = struct('Connectivity', 4, 'ImageSize', size(im.Data), ...
    'NumObjects', size(roi,1));
cc.PixelIdxList = {};
cc.NumPixels = [];
if contains(type, 'crystal')
    [x, y] = meshgrid(im.Grid1, im.Grid2);
    dist = 0.01*min(im.Grid1(end)-im.Grid1(1), im.Grid2(end) - im.Grid2(1));
    initialThresh = zeros(1, size(roi,1));
    for ii = 1:size(roi,1)
        ind = vecnorm([x(:), y(:)] - roi(ii,:),2,2) < dist;
        initialThresh(ii) = thresh*max(im.Data(ind));
    end
    % initialThresh = thresh*lookup(im, roi(:,1), roi(:,2)); % threshfrac
else
    initialThresh = thresh; % straight thresh
end

for ii = 1:cc.NumObjects

    % find initial cc based on roi

    imBack = removeBackground(im, initialThresh(ii));
    [test, ccii] = ccFilter(imBack, regSize, cc.Connectivity);
    ccInd = findClosestRegion(im, cc, ccii, roi(ii,:));

    % re-compute closest cc based on observed peak in initial cc

    if strcmpi(type, 'crystal')
        newThresh = thresh*max(im.Data(ccii.PixelIdxList{ccInd}));
        imBack = removeBackground(im, newThresh);
        [~, ccii] = ccFilter(imBack, regSize, cc.Connectivity);
        ccInd = findClosestRegion(im, cc, ccii, roi(ii,:));
    end

    cc.PixelIdxList = [cc.PixelIdxList, ccii.PixelIdxList(ccInd)];
    cc.NumPixels = [cc.NumPixels, ccii.NumPixels(ccInd)];
end

end

function ccInd = findClosestRegion(im, cc, ccii, roi)
smallestDist = inf;
for jj = 1:ccii.NumObjects
    ptsInd = ccii.PixelIdxList{jj};
    [rInd, cInd] = ind2sub(cc.ImageSize, ptsInd);
    dist = min(vecnorm(roi - [im.Grid1(cInd)' im.Grid2(rInd)],2,2));
    if dist < smallestDist
        smallestDist = dist;
        ccInd = jj;
    end
end
end