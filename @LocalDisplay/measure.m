% measure Measure display resolution
%
% The method measures display resolution with a resizeable figure.  The
% commands:
%    value=measure(object,width); % returns resolution as an output
%    measure(object,width);       % prints resolution in the command window
% generate a figure to be adjusted to match some physical width, which can
% be specified as a number with abbreviated unit: 'in' for inches, 'mm'
% for millimeters, or 'cm' for centimeters.  Certain paper
% sizes/orientations are also available.  See the readWidth method for more
% details.  The default width is '8.5in'.
%
% Once the figure is adjusted to match the specified width, the user closes
% it to complete the measurements.  Results are automatically passed to the
% set method when the ApplyMeasure property is 'on', but only stored when
% that property is 'off'.
%
% See also LocalDisplay, set, readWidth, verify
%
function varargout=measure(object,varargin)

% manage input
try 
    [width,value,unit]=readWidth(object,varargin{:});
catch ME
    throwAsCaller(ME);
end
name=sprintf('Set width to %g %s and close figure',value,unit);

% generate figure
previous=object.LastMeasure;
if isempty(previous)
    previous=object.LastSet;
    if isempty(previous)
        previous=object.Default;
    end
end

fig=uifigure('Name',name,'DeleteFcn',@callback,'WindowStyle','modal',...
    'Visible','off');
pixels=width*previous;
fig.Position(3:4)=pixels*[1 0.25];
movegui(fig,'center');
drawnow();
figure(fig);
    function callback(varargin)     
        pixels=fig.Position(3);
    end
uiwait(fig);
value=round(pixels/width);

setpref('LocalDisplay','LastMeasure',value);

% manage output
if nargout > 0
    varargout{1}=value;
else
    fprintf('Measured screen resolution is %g DPI\n',value);
end

% invoke set
if strcmp(object.ApplyMeasure,'on')
    set(object,value);
end

end