% under construction
%
function obj = calCombine(obj, ax)

%% input parsing

assert(contains(obj.calibration.type,'detector'), ...
    'Not valid for crystal calibrations');
assert(size(obj.calibration.poi,3) > 1, ...
    'Must have more than one poi set to combine')
assert(size(obj.calibration.poi,3) == numel(obj.calibration.cc.PixelIdxList), ...
    'Mismatch in cc and poi sizes');

cc = obj.calibration.cc;
poi = obj.calibration.poi;

%% code

% prompt user to select roi encomposing poi

roi = SMASH.ROI.Points('closed');
roi = select(roi,ax,'Lasso the POI of rings you wish to combine');
if isempty(roi)
    warning('No regions selected');
    return
end

% find regions corresponding to selection

ind = inpolygon(poi(:,1,:),poi(:,2,:),roi.Data(:,1),roi.Data(:,2));
combineInd = find(reshape(any(ind,1),1,[]));
if numel(combineInd) < 2
    warning('Fewer than 2 regions selected')
    return
end

% manually combine regions without calling calPOI and then make it
% impossible for future selections to auto-combine

newInd = combineInd(1);
deleteInd = combineInd(2:end);

cc.PixelIdxList{newInd} = vertcat(cc.PixelIdxList{combineInd});
cc.PixelIdxList(deleteInd) = [];
cc.NumPixels(newInd) = numel(cc.PixelIdxList(newInd));
cc.NumPixels(deleteInd) = [];
cc.NumObjects = numel(cc.NumPixels);
obj.calibration.cc = cc;

obj.calibration.poiFitResidual(newInd) = inf;
obj.calibration.poiFitResidual(deleteInd) = [];

maxInd = floor(size(poi,1)/numel(combineInd));
newPOI = [];
for ii = 1:numel(combineInd)
    newPOI = [newPOI; poi(1:min(maxInd,find(...
        isnan(poi(:,1,combineInd(ii))),1)-1),:,combineInd(ii))];
end
newPOI = [newPOI; nan(size(poi,1)-size(newPOI,1),2)];
poi(:,:,newInd) = newPOI;
poi(:,:,deleteInd) = [];
obj.calibration.poi = poi;

end
