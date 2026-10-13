% DELETEDETECTORHISTORY - delete detector image history
%
% This method deletes the detector image history and (optionally) the
% detector image itself.
%
% Usage:
%   >> obj = deleteDetectorHistory(obj)
%           -> delete detector image history
%   >> obj = deleteDetectorHistory(obj, 'target') 
%           -> delete match spots target image
%   >> obj = deleteDetectorHistory(obj, 'detector', true)
%           -> delete detector image history and detector image
%
% created September, 2026 by Nathan Brown (Sandia National Laboratories)
%
function obj = deleteDetectorHistory(obj, varargin)

type = 'detector';
everything = false;
if nargin > 1
    type = varargin{1};
end
if nargin > 2
    everything = varargin{2};
end

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
        obj.detector.imageHistory.preoutlier = -1;
    case 'target'
        obj.match.spots.target = -1;
end

end