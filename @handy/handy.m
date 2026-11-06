% Handy tool class
%
% This class provides handy tools for MATLAB users and developers.  These
% tools are accessed through various static methods.  For example:
%    handy.sysinfo(); 
% invokes the system information tool.
% 
classdef handy
    methods (Static=true)
        varargout=sysinfo(varargin)        
        varargout=environment(varargin)
        varargout=sysopen(varargin)
        varargout=isOctave(varargin)
        varargout=splitFile(varargin)
        varargout=checkGraphics(varargin)
        varargout=localPath(varargin)
        varargout=grabFile(varargin)
        varargout=importNamespace(varargin)
        varargout=superWhich(varargin)
        varargout=generateCall(varargin)
        varargout=truncate(varargin)
        varargout=compareFolders(varargin)
        varargout=portableFilename(varargin)
        varargout=timestamp(varargin)
        varargout=stashFile(varargin)
    end
    methods (Hidden=true)
        function object=handy(varargin)
        end
    end
end