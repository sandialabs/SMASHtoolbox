
% under construction
%
function obj = applySimGridToDet(obj)

if isa(obj.detector.image, 'SMASH.ImageAnalysis.Image')
    obj.detector.image = applySimGridToImage(obj, obj.detector.image);
end

end