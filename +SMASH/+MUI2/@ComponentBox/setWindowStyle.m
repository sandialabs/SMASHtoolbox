% setWindowStyle Set window style
%
% This method sets the window style for the component box figure.
%    setWindowStyle(object,value);
% The optional input "value" can be 'normal' (default), 'modal', or
% 'alwaysontop'.
% 
% See also ComponentBox
%
function setWindowStyle(object,value)

% manage input
Narg=nargin();
if (Narg < 2) || isempty(value)
    value='normal';
else
    valid={'normal' 'modal' 'alwaysontop'};
    assert(any(strcmpi(value,valid)),...
        'ERROR: window style must be ''%s'', ''%s'', or ''%s''',valid{:});
    value=lower(value);
end

% apply setting
for k=1:numel(object)
    set(object(k).Figure,'WindowStyle',value);
    object(k).WindowStyle=value;
end

end