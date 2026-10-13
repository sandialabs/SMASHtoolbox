% setName Set box name
%
% This method sets the component box name.
%    setName(object,value);
% Optional input "value" can be a character array or scalar string, with
% the default 'Control box'.  This value is shown at the top of component
% box window.
%
% See also ComponentBox
%
function setName(object,value)

Narg=nargin();
if (Narg < 2) || isempty(value)
    value='Control box';
else
    assert(ischar(value) || isStringScalar(value),...
        'ERROR: invalid control box name');
end

for k=1:numel(object)
    set(object(k).Figure,'Name',value);
    object(k).Name=value;
end

end