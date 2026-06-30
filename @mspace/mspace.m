% This class allows easy transitions between MATLAB workspaces.  A
% workspace includes: 
%   -Variables accessible in memory, i.e. within in the current scope
%   (command window or function).
%   -The current working directory.
%   -The current MATLAB path.
% Workspace information is retained entirely within memory, with
% optional disk back up.
%
% To illustrate this process, suppose you've been working for some time on
% Project A.  A colleague asks you to run a quick calculation on an
% unrelated Project B, but you don't want that calculation to mess up your
% work.  Separate workspaces permit both projects to exist in the same
% MATLAB session without conflicting with one another.
%    % work on project A
%    mspace.save('Project A'); % save work for project A
%    clear; % clear the workspace
%    % work on project B
%    mspace.save('Project B'); % save work on project B
%    mspace.load('Project A'); % return to be project A
%    % continue work on project A
% Existing workspaces can also be used in an interactive mode:
%    mspace.use(name);
% that changes the MATLAB prompt and evaluates all typed commands.
%
% Static methods provide all functionality for the mspace class; objects
% *cannot* be created.
%


classdef mspace
    %%
    methods (Static=true)
        varagout=save(varargin)
        varagout=load(varargin)
        varagout=show(varargin)
        varagout=lock(varargin)
        varagout=unlock(varargin)
        varagout=delete(varargin)
        varargout=select(varargin)
        varagout=evalin(varargin)
        varargout=describe(varargin)
        varagout=use(varargin)
    end
    %%
    methods (Hidden=true)
        function object=mspace(varargin)
        end
    end
    properties (Abstract=true, Hidden=true)
        Junk
    end
end