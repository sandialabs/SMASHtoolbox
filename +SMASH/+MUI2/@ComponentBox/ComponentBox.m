% This class creates user interfaces using a non-resizable figure.
% Graphical components are sequentially added to the figure, moving from
% left to right in a sequences of rows.  The process simplifies interface
% creation, allowing developers to focus on what each component does rather
% than where it should go on the screen.
%
% Object creation:
%    object=ComponentBox(mode);                        
% generates a figure where the various components will be rendered.
% Optional input "mode" controls whether this figure is initially visible
% or not. The default value 'hide' is recommended until the box is
% completely rendered, but the value 'show' can be useful for testing.
% Figure visibility can be changed with the hide and show methods.
%
% Various component blocks are added to the box with various class methods.
% Simple blocks contain a single component: message blocks are uilabels,
% button blocks are uibuttons, and so on.  Composite blocks combine several
% blocks, typically uilabel(s) with a more complex graphic (drop down menu,
% list box, table, and so forth).  Blocks are added horizontally until the
% newRow method is called, placing the next component at the box's left
% margin.  Each component size is based on the current font settings
% (default based on the calfont class) and optional width/height
% specifications.   Once all components have been added, the box can be fit
% to its content, placed on the screen, and made visible to the end user.
%
% Figure tools can be added to a component box through the appropriate
% MATLAB function.  For example:
%    main=uimenu(object.Figure,'Text','File');
%    sub=uimenu(main,'Text','Open');
% adds a menu at the top of the component box with one menu item.  Push and
% toggle tools can also be added to a toolbar:
%   tb=uitoolbar(object.Figure);
%   pb=uipushtool(tb);
% with context menus supported in a similar manner.
%    cm=uicontextmenu(object.Figure);
%    sub=uimenu(cm,'Text','Action 1');
% Instrumentation (gauges, knobs, lamps, or switches) and HTML components
% are not currently supported.
%
% Containers (panels and tabs) and axes objects are *not* meant to be used
% inside a component box.  However, box components can be copied to a
% separate figure (with its own containers and axes objects) or combined
% with a resizable panel.  Developers may create multiple boxes, each with
% a set of non-resizable components, for transfer to custom figure; the
% source boxes might then be deleted without ever being seen by the end
% user.
%
% NOTE: some components (such as text areas and list boxes) may be
% vertically larger than needed to accommodate the requested number of
% rows. This discrepancy arises from enforced consistency across across all
% components.  For example, drop down and table components require more
% vertical space per row than a list box rendered at the same font.  The
% philosophy of this class is that all components should span the same
% vertical space for a specified number of rows.
%
% See also SMASH.MUI2, calfont
%
classdef ComponentBox < handle    
    %% values that can be seen and changed by methods
    properties (SetAccess=protected)
        % Name Box name
        %
        % This property contains the current box name.  It is controlled
        % through the setName method.
        %
        % See also ComponentBox, setName  
        Name
        % Font Font settings
        %
        % This property contains the current font setting structure.  It is
        % controlled by the setFont method.
        %
        % See also ComponentBox, setFont
        Font
        % Margin Box margins
        %
        % This property contains the current margin structure.  It is
        % controlled by the setMargin method.
        %
        % See also ComponentBox, setMargin
        Margin
        % Gap Component gaps
        %
        % This property contains the component gap structure.  It is
        % controlled by the setGap method.
        %
        % See also ComponentBox, setGap
        Gap
        % LabelPosition Component label position
        %
        % This property contains the label position value ('above' or
        % 'left') used by some component blocks. It is controlled by the
        % setLabelPosition method.
        %
        % See also ComponentBox, setLabelPosition
        LabelPosition = 'left'
    end
    %% values than can seen but not directly changed
    properties (SetAccess=protected)
        Figure     % Figure Component box figure
        % WindowStyle Figure window style
        %
        % This property contains the window style for the component box
        % figure.  It is controlled by the setWindowStyle method.
        %
        % See also ComponentBox, setWindowStyle
        WindowStyle 
        Component  % Component Graphic handles for all box components
        CurrentRow % CurrentRow Graphic handles for components in the current row
        LabelQueue % LabelQueue Label queue structure
    end
    %% values for internal use
    properties (SetAccess=protected, Hidden=true)
        Calibration
        RowCounter = 1
    end
    properties (Hidden=true)
        DisplayUpdates = 'off';
    end
    methods
        function set.DisplayUpdates(object,value)
            valid={'on' 'off'};
            assert(any(strcmpi(value,valid)),...
                'ERROR: display updates must be ''%s'' or ''%s''',value{:})
            object.DisplayUpdates=lower(value);
        end
    end
    %% constructor
    methods (Hidden=true)
        function object=ComponentBox(visible)               
            % manage input 
            Narg=nargin();
            if (Narg < 1) || isempty(visible) || strcmpi(visible,'hide')
                visible='off';
            elseif strcmpi(visible,'show')
                visible='on';
            else
                error('ERROR: invalid figure state');
            end
             % create and set up figure
            object.Figure=uifigure('Visible',visible,...
                'Resize','off','DeleteFcn',@(~,~) delete(object),...
                'WindowStyle','normal','AutoResizeChildren','off');
            try %#ok<TRYNC>
                set(object.DockControls,'off'); % may not work before 2025a          
            end
            locate(object,'northeast'); % useful for debugging
            setFont(object);
            setMargin(object);
            setGap(object);
            setName(object);
            applyFont(object);
            setLabelPosition(object);
            setWindowStyle(object);
            flushLabel(object);
        end
    end
    %%
    methods (Static=true)
        varargout=demonstrate(varargin)
        varargout=createExample(varargin)
    end
    %% hidden methods
    methods (Hidden=true)
        function delete(object)
            try %#ok<TRYNC>
                delete(object.Figure);
            end
        end
        varargout=checkDisplay(varargin)
        varargout=getStaging(varargin)
        varargout=applyFont(varargin)
        varargout=calculateSize(varargin)
        varargout=refresh(varargin)
        %varargout=lookup(varargin)
        varargout=checkCurrentRow(varargin)
    end
    %% hide extraneous features for clarity
    methods (Hidden=true)
        %%
        function result=addlistener(varargin)
            result=addlistener@handle(varargin{:});
        end
        function result=eq(varargin)
            result=eq@handle(varargin{:});
        end
        function result=findobj(varargin)
            result=findobj@handle(varargin{:});
        end
        function result=findprop(varargin)
            result=findprop@handle(varargin{:});
        end
        function result=ge(varargin)
            result=ge@handle(varargin{:});
        end
        function result=gt(varargin)
            result=gt@handle(varargin{:});
        end
        function result=le(varargin)
            result=le@handle(varargin{:});
        end
        function result=lt(varargin)
            result=lt@handle(varargin{:});
        end
        function result=listener(varargin)
            result=listener@handle(varargin{:});
        end
        function result=ne(varargin)
            result=ne@handle(varargin{:});
        end
        function result=notify(varargin)
            result=notify@handle(varargin{:});
        end
    end

end