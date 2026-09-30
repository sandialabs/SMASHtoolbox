% generateCall Generate namespace call
%
% This *static* method generates a handle for calling function, class
% constructor, or static method located within a namespace.
%    fcn=handy.generateCall(target,ns);
% Here "target" indicates the item to be called from namespace "ns".  Both
% inputs are required when this tool is used in the command window or
% whenever an absolute namespace needs to be specified.  The output "fcn"
% is a function handle that evaluated as fcn(...).  Passing an empty
% target:
%    library=handy.generateCall('',ns);
% returns a structure "library" with fields for every available function,
% class constructor, and static method (using '_' instead of '.' as a
% separator).  Each structure field contains a function handle for calling
% the named item. 
%
% Automatic namespace detection is available when this tool is used inside
% a function or method.
%    fcn=handy.generateCall(target); % specific function handle
%    library=handy.generateCall();   % function handle structure
% This approach allows code to invoke other code from the name space
% without explicilty knowing that that (possibly) namespace is called.
% For best performance, namespace calls should be generated once and stored
% in a persistent variable.
%
% Relative calls can be defined using the "-" character.  For example:
%    fcn=handy.generateCall('-.',ns);
% references the parent namespace, whether it was defined explicitly or
% implicitly ("ns" is empty or omitted).
%
% See also handy
%
function out=generateCall(target,ns)

% manage input
Narg=nargin();
if (Narg < 1) || isempty(target)
    target='';
else
    assert(ischar(target) || isStringScalar(target),...
        'ERROR: invalid call target');
    target=char(target);
end

if (Narg < 2) || isempty(ns)
[st,~]=dbstack('-completenames');
    assert(~isscalar(st),...
        'ERROR: tool must be used inside a function/method');
    ns=st(2).file;
    assert(contains(ns,'+'),'ERROR: tool must be used inside a namespace');
    ns=extractAfter(ns,'+');
    ns=strrep(ns,[filesep() '+'],'.');
    if contains(ns,'@')
        ns=extractBefore(ns,[filesep() '@']);
    end    
else
    assert(ischar(ns) || isStringScalar(ns),'ERROR: invalid namespace');
    ns=char(ns);
end

% finalize namespace
ERRMSG='ERROR: invalid prefix';
while ~isempty(target) && (target(1) == '-')
    assert(target(2) == '.',ERRMSG);
    target=target(3:end);
    k=strfind(ns,'.');
    assert(~isempty(k),ERRMSG);
    ns=ns(1:k(end)-1);
    assert(~isempty(ns),ERRMSG);
end

ns=matlab.metadata.Namespace.fromName(ns);
assert(~isempty(ns),'ERROR: namespace not found');

% generate all possible calls when no specific request is made
if isempty(target)
    out=struct();
    for n=1:numel(ns.FunctionList)
        name=ns.FunctionList(n).Name;
        target=[ns.Name '.' name];
        out.(name)=str2func(target);
    end
    for n=1:numel(ns.ClassList)
        name=ns.ClassList(n).Name;
        short=extractAfter(name,[ns.Name '.']);
        if ~ns.ClassList(n).Abstract
            out.(short)=str2func(name);
        end
        for m=1:numel(ns.ClassList(n).MethodList)
            potential=ns.ClassList(n).MethodList(m);
            if ~potential.Static || potential.Abstract || potential.Hidden
                continue
            end
            target=[ns.Name '.' short '.' potential.Name];
            out.([short '_' potential.Name])=str2func(target);
        end
    end
    return
end

% look for function calls
for n=1:numel(ns.FunctionList)
    if strcmp(ns.FunctionList(n).Name,target)
        out=str2func([ns.Name '.' target]);
        return
    end
end

% look for class constructor and static method calls
if contains(target,'.')
    k=strfind(target,'.');
    assert(isscalar(k),'ERROR: invalid target');
    mName=target(k+1:end);
    cName=target(1:k-1);
else
    mName='';
    cName=target;
end

for n=1:numel(ns.ClassList)
    name=ns.ClassList(n).Name;
    short=extractAfter(name,[ns.Name '.']);
    if strcmp(short,cName) && isempty(mName)
        out=str2func([ns.Name '.' target]);
        return
    elseif isempty(mName)
        continue
    end
    for m=1:numel(ns.ClassList(n).MethodList)
        potential=ns.ClassList(n).MethodList(m);
        if ~potential.Static || potential.Abstract || potential.Hidden
            continue
        elseif ~strcmp(potential.Name,mName)
            continue
        end
        out=str2func([ns.Name '.' cName '.' potential.Name]);
        return
    end
end

% give up
error('ERROR: "%s" not found in "%s"',target,ns.Name);

end