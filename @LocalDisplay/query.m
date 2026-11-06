% query Query display resolution using Java
%
% This method uses Java to query the display resolution.  The value can be
% returned as an output:
%   value=query(object);
% or printed in the command window.
%    query(object);
%
% NOTE: this method will *not* work without Java graphics.  Future MATLAB
% releases may not support this feature
%
% See also LocalDisplay, measure, set, verify
%
function varargout=query(~)

try
    object=java.awt.Toolkit.getDefaultToolkit();
catch
    error('ERROR: unable to query display with Java');
end
value=object.getScreenResolution();

% manage ouput
if nargout > 0
    varargout{1}=value;
else
    fprintf('Java reports display resolution as %g DPI\n',value);
end

end