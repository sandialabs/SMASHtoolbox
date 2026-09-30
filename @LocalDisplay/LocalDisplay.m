% Local display class
%
% This class manages local display resolution.  Complexities between
% operating system, display type, and multiple displays make it difficult
% to enforce physical scaling of displayed graphics.  For example, a figure
% sized to be precisely 8.5" wide on one display often appears different
% when dragged one display to another in a multi-display system.  Even in
% single-display systems, queries about the screen resolution are often
% unreliable: MATLAB assumes that Macs operate at 72 dots per inch,
% although this is almost never the case.  This class allows users to
% mitigate this problem.
%
% Object construction is simple.
%    object=LocalDisplay(DPI);
% The optional input "DPI" invokes the set method, which is bypassed if
% this argument is empty or omittedl.  Object properties indicate the
% default resolution, as well as the last setting and measurment (if any).
%
% NOTE: Only one physical resolution, or dots per inch (DPI), can be
% managed at any time.  Typically this is done for the primary display.
% Users should be aware that moving figures from one display to another may
% result in physical size changes.
%
classdef LocalDisplay
    %%
    properties (Dependent=true, SetAccess=protected)
        Default     % System default resolution
        LastSet     % Last resolution setting
        LastMeasure % Last resolution measurement      
        Current     % Current resolution is last setting (if available) or default
    end
    methods
        function value=get.Default(~)
            value=get(groot(),'ScreenPixelsPerInch');
        end
        function value=get.LastSet(~)
            if ispref('LocalDisplay','LastSet')
                value=getpref('LocalDisplay','LastSet');                
            else
                value=[];
            end
        end
        function value=get.LastMeasure(~)
            if ispref('LocalDisplay','LastMeasure')
                value=getpref('LocalDisplay','LastMeasure');
            else
                value=[];
            end
        end
        function value=get.Current(object)
            if ~isempty(object.LastSet)
                value=object.LastSet;
            else
                value=object.Default;
            end
        end
    end
    %%
    properties
        ApplyMeasure = 'on' % Automatically apply measurements ('on' or 'off')
    end
    methods
        function object=set.ApplyMeasure(object,value)
            if any(strcmpi(value,{'on' 'off'}))
                object.ApplyMeasure=lower(value);
            else
                error('ERROR: apply measurement must be ''on'' or ''off''');
            end
        end
    end
    %%
    properties (Constant=true)
        PointsPerInch = 72.27       % Points to inch scaling
        MillimetersPerInch = 25.4   % Millimeter to inch scaling
    end   
    %%
    methods (Hidden=true)
        function object=LocalDisplay(varargin)
            if nargin > 0
                try
                    set(object,varargin{:});
                catch ME
                    throwAsCaller(ME);
                end
            end
        end
        varargout=sizeControl(varargin);
    end   
end