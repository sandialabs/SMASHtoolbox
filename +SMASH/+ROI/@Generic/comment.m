% comment Add/edit comments
%
% This method brings up interactive window for adding and editing comments
%    object=comment(object);
%
function object=comment(object)

font=struct('Name','','Size',14);
try %#ok<TRYNC>
    Q=calfont.lookup();
    font.Name=Q.Name;
    font.Size=Q.Size;
end

default={strtrim(object.Comments)};
switch lower(SMASH.Graphics.checkGraphics())
    case 'java'
        answer=commentLegacy(default,font);
    case 'javascript'
        answer=commentCurrent(default,font);
end

if isnumeric(answer)
    % do nothing
else
    object.Comments=answer{1};
end

end

function answer=commentLegacy(default,font)

dlg=SMASH.MUI.Dialog('FontName',font.Name,'FontSize',font.Size);
dlg.Hidden=true();
dlg.Name='ROI comments';

hText=addblock(dlg,'medit','ROI comments:',40,10);
set(hText(1),'FontWeight','bold');
set(hText(2),'String',default);

h=addblock(dlg,'button',{'Done' 'Cancel'},6);
set(h(1),'Callback',@done);
    function done(varargin)
        answer=get(hText(2),'String');
        delete(dlg);
    end
set(h(2),'Callback',@cancel);
    function cancel(varargin)
        answer=0;
        delete(dlg);
    end

locate(dlg,'center');
show(dlg);
uiwait(dlg.Handle);

end

function answer=commentCurrent(default,font)

cb=SMASH.MUI2.ComponentBox();
setFont(cb,font.Name,font.Size);
setName(cb,'ROI comments');

hText=addTextarea(cb,40,10);
set(hText(1),'Text','ROI comments:','FontWeight','bold');
set(hText(2),'Value',default);
newRow(cb);

h=addButton(cb,6);
set(h,'Text','Done','ButtonPushedFcn',@done);
    function done(varargin)
        answer=get(hText(2),'Value');
        delete(cb);
    end
h=addButton(cb,6);
set(h,'Text','Cancel','ButtonPushedFcn',@cancel);
    function cancel(varargin)
        answer=0;
        delete(cb);
    end

fit(cb);
locate(cb,'center');
show(cb);

setWindowStyle(cb,'modal');
uiwait(cb.Figure);

end