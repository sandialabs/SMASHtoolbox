function [fig, ax] = showImage(im, msg)
h = view(im);
fig = h.figure; 
ax = h.axes;
title(ax, msg)
axis(ax,'equal');
set(fig, 'Position', get(0, 'Screensize'));
drawnow; % necessary in 2025b for the first DENNIS autocal in a MATLAB session
end