function aboutSIRHEN(varargin)

parent=gcbf();

dlg=findall(groot,'Type','figure','Tag','aboutSIRHEN');
if ~isempty(dlg)
    delete(dlg);
end


switch SMASH.Graphics.checkGraphics()
    case 'Java'
        showLegacy(parent);
    case 'JavaScript'
        showCurrent(parent);
end

end

function showLegacy(parent)

dlg=SMASH.MUI.Dialog();
dlg.Hidden=true;
dlg.Name='About SIRHEN';

addblock(dlg,'text',{'SIRHEN 2.0' 'May 2023'});

locate(dlg,'center',parent);
dlg.Hidden=false;

set(dlg.Handle,'Tag','aboutSIRHEN','HandleVisibility','callback');

end

function showCurrent(parent)

cb=SMASH.MUI2.ComponentBox();
setName(cb,'About SIRHEN');
set(cb.Figure,'Tag','aboutSIRHEN');

message={'SIRHEN program for PDV analysis',...
    'Version 2.0 (updated September 2025)'};
pushLabel(cb,message);
popLabel(cb,'message',numel(message));

fit(cb);
locate(cb,'center',parent);
show(cb);

end