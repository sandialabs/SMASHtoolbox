%
function obj = deleteDetectorHistory(obj, type, everything)

switch type
    case 'detector'
        if everything
            obj.detector.image = -1;
        end
        obj.detector.imageHistory.original = -1;
        obj.detector.imageHistory.lastsave = -1;
        obj.detector.imageHistory.precrop = -1;
        obj.detector.imageHistory.prebackground = -1;
        obj.detector.imageHistory.premask = -1;
        obj.detector.imageHistory.prescale = -1;
        obj.detector.imageHistory.preccfilter = -1;
        obj.detector.imageHistory.presmooth = -1;
        obj.detector.imageHistory.prebandpassfilter = -1;
        obj.detector.imageHistory.prereversemask = -1;
        obj.detector.imageHistory.prefillmissing = -1;
    case 'target'
        if everything
            obj.match.image.target = -1;
        end
end

end