% This function requires 2018b or later Image Processing Toolbox!

function [ind, diam] = drawCircle(ax, varargin)

% parse input

type = 'circle';
if nargin > 1
    type = varargin{1};
end

% draw circle and let user edit it

xlims = xlim(ax);
ylims = ylim(ax);
x = diff(xlims)/2 + xlims(1);
y = diff(ylims)/2 + ylims(1);
rad = min(diff(xlims), diff(ylims))/2;

switch type
    case 'circle'
        roi = drawcircle(ax, 'Color', 'w', 'LineWidth', 1.5, 'Center', [x y], ...
            'radius', rad, 'FaceAlpha', 0, 'DrawingArea', 'unlimited');
    case 'ellipse'
        roi = drawellipse(ax, 'Color', 'w', 'LineWidth', 1.5, 'Center', [x y], ...
            'semiaxes', [rad rad]/10, 'FaceAlpha', 0, 'DrawingArea', 'unlimited');
end
drawnow; % necessity that may go away with later MATLAB verions
uiwait(ancestor(ax, 'figure')); % resumes on any key press b/c I set WindowKeyPressFcn to uiresume (pause now requires the user to first select the Command Window)
roi.Visible = 'off';

% generate mask

ind = createMask(roi);

if strcmpi(type,'circle')
    diam = 2*roi.Radius;
end

end