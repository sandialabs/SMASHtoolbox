function [poi, poiIntensity] = findCrystalPOI(im, roi, cc, poiType)

if strcmp(poiType, 'exact')
    poi = roi;
    poiIntensity = lookup(im, poi(:,1), poi(:,2));
else
    [poi, poiIntensity] = findSpotPoints(im, cc, poiType);
end

end

function [spotPoints, spotIntensities] = findSpotPoints(im, cc, poiType)

% loop through cc regions and pick out either the weighted mean or the
% maximum value

spotPoints = nan(cc.NumObjects,2); % [pt, xy]
spotIntensities = nan(cc.NumObjects,1);
for ii = 1:cc.NumObjects
    ptsInd = cc.PixelIdxList{ii};
    w = im.Data(ptsInd);
    spotIntensities(ii) = mean(w); % already thresholding in cc determination
    [r, c] = ind2sub(cc.ImageSize, ptsInd);
    switch poiType
        case 'mean'
            spotPoints(ii,:) = sum(w.*[im.Grid1(c)', im.Grid2(r)])/sum(w);
        case 'max'
            [~, maxInd] = max(w);
            spotPoints(ii,:) = [im.Grid1(c(maxInd)), im.Grid2(r(maxInd))];
    end
end

end