% This class supports font calibration.  Font calibration links a specific
% name (e.g., Helvetica) and size (in pixels) to vertical/horizontal size
% requirements for user interface components (labels, buttons, etc.) to fit
% the text contained within.  Objects are never constructed from this
% *abstract* class--all functionality is provided through static methods.
%
% Four types of information are determined in a font calibration.
%    1. Pixel width as captured by the textWidthFcn function, which expects
%       numeric input for the number of columns.  The output is a tight fit
%       for the requested number of horizontal "W" characters in a uilabel.
%    2. Pixel height as captured by the textHeightFcn function, which
%       expects a numeric input for the number of rows.  The output is 
%       larger than the vertical requirements of a uilabel--extra space is 
%       allocated to to support components such uibuttons and uidropdown
%       with the requested number of vertical "W" characters.
%    3. Pixel height of the (square) check boxes on the current system as 
%       captured by the boxSizeFcn function (usually independent of font).
%    4. Effective character widths as captured by the WidthFcn function, 
%       which accepts numeric (ASCII codes), character array, cell array 
%       of character vectors, or string arguments.  This function accepts
%       two inputs and returns two outputs.
%          [effective,total]=WidthFcn(arg,padding)
%       The output "total" expresses the maximum number of characters
%       needed to hold all elements of input "arg".  The output "effective"
%       accounts for variable character widths in proportional fonts; the
%       outputs are identical (before padding) for fixed width fonts.
%       Optional input "padding" defines extra characters added to
%       "effective" for component clarity; the default value is 0.
% Once a calibrated font is added, these functions remain available
% throughout the MATLAB session, even after workspace is cleared.
% Calibrations are automatically deleted whenever the number of displays
% and/or screen resolution changes.
%
% A specific application of this class is for developers to base a
% graphical interface around the end user's preferred font.  Essentially,
% the interface would look to see if the user had chosen a particular font
% and the apply that calibration during interface construction.
% 
% NOTE: font calibrations are based on plain text.  Components with 'latex'
% or 'tex' interpretation many not be consistent with calculations
% predictions based on any of the functions described above.
%
% Created 2025 by Dan Dolan (WSU)
%
classdef (Abstract) calfont
    methods (Hidden=true)
        function object=calfont(varargin)
        end
    end
    methods (Static=true)
        varargout=add(varargin) 
        varargout=charset(varargin)
        varargout=check(varargin)
        varargout=choose(varargin)
        varargout=get(varargin)
        varargout=lookup(varargin)
        varargout=query(varargin)
        varargout=remove(varargin)
        varargout=reset(varargin)
        varargout=show(varargin)
        varargout=set(varargin)
    end
end