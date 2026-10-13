function obj = setImageDependentDetectorCalDefaults(obj)
if ~isa(obj.detector.image, 'SMASH.ImageAnalysis.Image')
    return
end
num = sqrt(numel(obj.detector.image.Data));
obj.calibration.opts.minRegSize = round(num/2.048);
obj.calibration.opts.minPointDist = round(num/102.4);
obj.calibration.opts.maxPointNum = round(num/20.48);
obj.calibration.opts.gaussianSigma = round(num/100);
end