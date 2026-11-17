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
roi.Selected = true;
ax.InteractionOptions.DatatipsSupported = 'off'; % in 2025b, not doing this makes altering the circle laggy

% necessary in case user never edits the roi:
fig = ancestor(ax, 'figure');
callbck = get(gcbo, 'ButtonPushedFcn');
set(gcbo, 'ButtonPushedFcn', @(src,event)uiresume(fig));
uiwait(fig); % paired with processDlg WindowKeyPressFcn
set(gcbo, 'ButtonPushedFcn', callbck);

roi.Visible = false;
ax.InteractionOptions.DatatipsSupported = 'on';

% generate mask

ind = createMask(roi);

if strcmpi(type,'circle')
    diam = 2*roi.Radius;
end

end