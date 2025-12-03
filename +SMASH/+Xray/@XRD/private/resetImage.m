%
function obj = resetImage(obj, type, everything)

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
    case 'target'
        if everything
            obj.simulation.target = -1;
        end
        obj.simulation.targetHistory.original = -1;
        obj.simulation.targetHistory.prebackground = -1;
        obj.simulation.targetHistory.premask = -1;
        obj.simulation.targetHistory.prereversemask = -1;
        obj.simulation.targetHistory.preccfilter = -1;
        obj.simulation.targetHistory.presmooth = -1;
        obj.simulation.targetHistory.prebandpassfilter = -1;
end

end