% flushLabel Clear label queue
%
% This methods flushes the label queue.
%    flushLabel(object);
% No new components can be popped from the queue until new labels are
% pushed.
%
% See also ComponentBox, popLabel, pushLabel
%
function flushLabel(object)

Q.Width=10;
Q.Content={};
object.LabelQueue=Q;

end