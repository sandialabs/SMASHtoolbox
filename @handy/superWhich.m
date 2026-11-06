% superWhich Enhanced file locator
%
% This *static* method is an enhanced version of MATLAB's which command.
%    source=handy.superWhich(item);
% Mandatory input "item" defines the file/folder to be located.  Valid
% items include: function/class/method names, namespaces, and existing
% variables.  In all cases, an absolute file/folder name is returned in the
% output "source".  
%
% See also handy, which
%
function source=superWhich(item)

assert((nargin() > 0) && ~isempty(item),'ERROR: no item specified');
source=[];

% function/class name
try %#ok<TRYNC>
    source=which(item);
    assert(~isempty(source));
    if startsWith(source,'built-in')
        source=extractAfter(source,'(');
        source=extractBefore(source,')');
        source=fileparts(source);
    end
    return
end

% variable
if ~ischar(item) && ~isStringScalar(item)
    item=class(item);
    source=handy.superWhich(item);
    return
end

% explicit location
if isfile(item) || isfolder(item)
    source=item;
    return
end

% namespace
z=matlab.metadata.Namespace.fromName(item);
assert(~isempty(z),'ERROR: requested source not found');

buffer=path();
mark=pathsep();
item=strrep(item,'.',[filesep() '+']);
item=['+' item];
while ~isempty(buffer)
    current=extractBefore(buffer,mark);
    if isempty(current)
        current=buffer;
        buffer='';
    else
        buffer=extractAfter(buffer,mark);
    end
    temp=fullfile(current,item);
    if isfolder(temp)
        source=temp;
        break
    end
end

end