% SIRHEN2 Sandia InfraRed HeterodynE aNalysis program, version 2.0
%
% This program analysis Photonic Doppler Velocimetry (PDV) measurements,
% also known as heterodyne velocimetry.  The program is called with no
% input or output arguments.
%    SIRHEN2
% 
% See also loadSMASH, SIRHEN
%
function varargout=SIRHEN2(points)

if nargin() < 1
    points=12;
end

% launch GUI
switch SMASH.Graphics.checkGraphics()
    case 'Java'
        previous=SMASH.MUI.setFonts();
        setProgramFont()
        fig=createGUI_Legacy();
        SMASH.MUI.setFonts(previous);
    case 'JavaScript'
        if isempty(calfont.query())
            calfont.add('',points);
        end
        commandwindow();
        fprintf('Launching GUI...');
        fig=createGUI_Current();
        fprintf('done\n');
end

% manage output
if isdeployed
    varargout{1}=0;
elseif nargout > 0
    varargout{1}=fig;
end

end