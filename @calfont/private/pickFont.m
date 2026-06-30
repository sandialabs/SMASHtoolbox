% pickFont Interactive font selection
% 
% This function provides interactive font name/size selection.
%   [name,pixels]=pickFont(name,pixels);
% Optional input "name" defines the initial font name, defaulting to
% 'Helvetica'.  Optional input "pixels" defines the initial font size,
% defaulting to 12.  Errors are generated when the requested font is not
% available on the current system or the number of pixels is not a number
% >= 3.
%
% The user is shown a graphical interface for selecting a font name and
% size, with sample text illustrating the font's appearance.  Pressing the
% "OK" button returns the current selection as outputs outputs "name" and
% "pixels".  These outputs are empty when the "Cancel" button is pressed or
% the interface is manually closed. 
%
% See also listfonts, uisetfont
%

function [name,pixels]=pickFont(name,pixels)

% manage input
fonts=listfonts();
Narg=nargin();
if (Narg < 1) || isempty(name)
    name='Helvetica';
else
    index=strcmpi(name,fonts);
    assert(any(index),'ERROR: requested font not found');
    name=fonts(index);
    name=name{1};
end

if (Narg < 2) || isempty(pixels)
    pixels=12;
else
    assert(isnumeric(pixels) && isscalar(pixels) && (pixels >= 3),...
        'ERROR: size must be a number >= 3 pixels');
end

% create interface
fig=uifigure('Units','pixels',...
	'Position',[1 1 372.365 222.125],...
	'Name','Pick font',...
	'Resize',0,...
	'Scrollable',0);

h1=matlab.ui.control.Label('Parent',fig,...
	'Position',[10 189.359 168.685 22.7656],...
	'FontName','Helvetica','FontSize',12,...
	'VerticalAlignment','bottom',...
	'Text','Name:',...
	'FontWeight','bold'); %#ok<NASGU>

h2=matlab.ui.control.DropDown('Parent',fig,...
	'Position',[10 166.594 185.685 22.7656],...
	'FontName','Helvetica','FontSize',12);
set(h2,'Items',fonts,'Value',name,'ValueChangedFcn',@pickName);
    function pickName(varargin)        
        set(h6,'FontName',h2.Value)
    end

h3=matlab.ui.control.Label('Parent',fig,...
	'Position',[249.24 189.359 113.125 22.7656],...
	'FontName','Helvetica','FontSize',12,...
	'VerticalAlignment','bottom',...
	'Text','Size:',...
	'FontWeight','bold'); %#ok<NASGU>

h4=matlab.ui.control.Spinner('Parent',fig,...
	'Position',[249.24 166.594 113.125 22.7656],...
	'FontName','Helvetica','FontSize',12,...
	'Value',3,...
	'Limits',[3 Inf],...
	'RoundFractionalValues',1,...
	'ValueDisplayFormat','%d pixels');
set(h4,'Value',pixels,'ValueChangedFcn',@pickPixels);
    function pickPixels(varargin)
        set(h6,'FontSize',h4.Value)
    end

h5=matlab.ui.control.Label('Parent',fig,...
	'Position',[10 133.828 335.365 22.7656],...
	'FontName','Helvetica','FontSize',12,...
	'VerticalAlignment','bottom',...
	'Text','Sample text:',...
	'FontWeight','bold'); %#ok<NASGU>

SampleText={ 'The quick fox jumped over the lazy dog.   1234567890'};
h6=matlab.ui.control.TextArea('Parent',fig,...
	'Position',[10 42.7656 352.365 91.0625],...
	'FontName','Helvetica','FontSize',12);
set(h6,'Value',SampleText,'ValueChangedFcn',@updateSample,...
    'Tooltip','Sample text can be edited; empty value restores default');
    function updateSample(varargin)
        current=strtrim(h6.Value{1});
        if isempty(current)
            h6.Value=SampleText;
        end
    end
pickName();
pickPixels();

h7=matlab.ui.control.Button('Parent',fig,...
	'Position',[227.234 10 57.5651 22.7656],...
	'FontName','Helvetica','FontSize',12,...
	'Text','OK');
set(h7,'ButtonPushedFcn',@ok);
    function ok(varargin)
        name=h2.Value;
        pixels=h4.Value;
        delete(fig);
    end

h8=matlab.ui.control.Button('Parent',fig,...
	'Position',[304.799 10 57.5651 22.7656],...
	'FontName','Helvetica','FontSize',12,...
	'Text','Cancel');
set(h8,'ButtonPushedFcn',@cancel);
    function cancel(varargin)
        delete(fig);
    end

movegui(fig,'center');
name='';
pixels=[];

set(fig,'WindowStyle','modal');
uiwait(fig);

end