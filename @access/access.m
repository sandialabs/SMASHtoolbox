% access Access files
%
% This *abstract* class accesses files without knowledge of their absolute
% location.  Files are referenced by source file, class, or package on the
% current MATLAB path.
% 
% Consider the following file system.
%    myfolder/program1.m
%    myfolder/+MyPackage/program2.m
%    myfolder/+MyPackage/info.txt
%    myfolder/+MyPackage/archive/
%    myfolder/@MyClass/MyClass.m 
%    myfolder/@MyClass/analyze.m
%    myfolder/@MyClass/data.txt
%    myfolder/@MyClass/private/
% The function program1.m, package function program2.m, and class
% definition MyClass.m are directly accessible when "myfolder" is on the
% MATLAB path.  However, the files "info.txt" and "data.txt" are not
% normally accessible, nor are the "archive" and "private" subdirectories.
%
% The static methods of this class allow access to:
%    -All files MyPackage, not just the functions.
%    -All files in MyClass, not just the methods.
%    -All package and class subdirectories
% Using "MyPackage" or "MyClass" as sources permits access to all files
% within their respective directories without explict reference to
% "myfolder".
% 
classdef (Abstract) access
    %%
    methods (Hidden=true)
        function object=access(varargin)
        end
    end
    %%
    methods (Static=true)
        varagout=getFolder(varargin)
        varargout=dir(varargin)
        varargout=edit(varargin)
    end
end