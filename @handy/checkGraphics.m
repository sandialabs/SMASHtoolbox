% checkGraphics Check for Java/JavaScript graphics
%
% This *static* method checks the graphics system used by MATLAB.
%    value=handy.checkGraphics();
% Output "value" indicates whether 'Java' or 'JavaScript' graphics are in
% use.  Omitting the output:
%    handy.checkGraphics();
% prints a message in the command window indicating the graphic system.
%
% NOTE: the returned value denotes the *primary* graphic
% system being used.  JavaScript graphics have been available since MATLAB
% release 2015b, but Java was still used for standard figures.  Java
% graphics were removed in the new desktop beta and formally replaced in
% release 2025a.  This function allows developers to detect whether legacy
% code based on Java graphics can be used or if JavaScript alternatives are
% required.  In summary, this function returns:
%    -'Java' for all releases through R2023a.
%    -'JavaScript' for all release R2025a and later.
%    -'JavaScript' for releases R2023b, R2024a, and R2024b using the new
%    desktop beta and 'Java' otherwise.
%
% See also handy
%
function varargout=checkGraphics()

mlock();
persistent installed year ginfo
if isempty(installed)
    installed=version('-release');
    year=sscanf(installed,'%g',1);
end

if (year <= 2023) || strcmpi(installed,'2023a')
    value='Java';
elseif year >= 2025
    value='JavaScript';
else
    if isempty(ginfo)
        try
            ginfo=rendererinfo();
        catch
            ginfo.GraphicsRenderer='';
        end
    end
    if strcmpi(ginfo.GraphicsRenderer,'WebGL')
        value='JavaScript';
    else
        value='Java';
    end
end

% manage output
if nargout() > 0
    varargout{1}=value;
else
    fprintf('MATLAB is using %s graphics\n',value);
end

end