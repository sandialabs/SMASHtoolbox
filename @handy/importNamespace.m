% importNamespace Import classes/functions from a namespace
%
% This *static* method imports classes and functions from a namespace.
%    Q=handy.importNamespace(name);
% Input "name" explicitly specifies the namespace that will be imported.
% This input *can* be omitted/empty when this method is invoked within a
% namespace, in which case classes and functions adjacent to the calling
% file are imported.  The output "Q" is a structure with short (name space
% omitted) field names for each imported class and function.  The value of
% each field is a function handle and *must* therefore be invoked with
% parenthesis.
% 
% To illustrate how importing works, consider a simple namespace called
% "example" inside a parent folder on the MATLAB path.
%    (parent)/+example/@myclass/
%    (parent)/+example/myfunctionA.m
%    (parent)/+example/myfunctionB.m
% Absolute calls to this code are made as follows.
%    obj=example.myclass(...);
%    [...]=example.myfunctionA(...);
%    [...]=example.myfunctionB(...);
% The following commands can be used in any location.
%    Q=handy.import('example');
%    obj=Q.myclass(...);
%    [...]=Q.myfunctionA(...);
%    [...]=Q.myfunctionB(...);
% Note that parenthesis *must* be used on the right hand side, even when
% the class/function being called does not require output.  Omitting the
% parenthesis reference the function handle stored in "Q" rather than
% invoking the class/function (typically what one wants to do).
%
% Using the command:
%    Q=handy.importNamespace();
% from code in the namespace folder allows adjacent references between
% files.  For example, "myfunctionA" might reference "myfunctionB".  Rather
% than explicitly referencing the namespace "example", which might change
% or become nested in another namespace, the import recognizes that the two
% functions and class definition exist in the same location.
%
% For best performance, the output structure from this method should be
% stored in a persistent variable.  Doing so avoids the repeated overhead
% of namespace reconciliation and analysis.
%
% See also handy
%
function out=importNamespace(ns)

% manage input
Narg=nargin();
if (Narg < 1) || isempty(ns)
    [st,~]=dbstack('-completenames');
    assert(~isscalar(st) && contains(st(2).file,'+'),...
        'ERROR: request is not part of a namespace');
    temp=[filesep() '+'];
    target=extractAfter(st(2).file,temp);
    while true
        [location,sub]=fileparts(target);
        if sub(1) == '+'
            break
        end
        target=location;
    end
    ns=strrep(target,temp,'.');
else
    assert(ischar(ns) || isStringScalar(ns),...
        'ERROR: invalid namespace request');    
end

% verify and import namespace
z=matlab.metadata.Namespace.fromName(ns);
assert(~isempty(z),'ERROR: requested source not found');

out=struct();
for n=1:numel(z.ClassList)
    full=z.ClassList(n).Name;
    k=strfind(full,'.');
    short=full(k(end)+1:end);
    out.(short)=str2func(full);
end
for n=1:numel(z.FunctionList)
    name=z.FunctionList(n).Name;
    out.(name)=str2func([z.Name '.' name]);
end

end