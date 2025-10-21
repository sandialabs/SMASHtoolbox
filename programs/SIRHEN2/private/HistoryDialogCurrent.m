function object=HistoryDialogCurrent(object,SourceFigure)

cb=SMASH.MUI2.ComponentBox();
setName(cb,'History analysis');

message={};
message{end+1}='Power spectrum centroids';
N=numel(object.ROIselection);
switch N
    case 0
        message{end+1}='No ROI selection';
    case 1
        message{end+1}='1 ROI selection';
    otherwise
        message{end+1}=sprintf('%d ROI selections',N);
end
pushLabel(cb,message);
popLabel(cb,'message',numel(message));
newRow(cb);

pushLabel(cb,'Generate history','Close');
GenerateButton=popLabel(cb,'button');
set(GenerateButton,'ButtonPushedFcn',@generateHistoryCallback)
    function generateHistoryCallback(varargin)
        h=findobj(cb.Figure,'Enable','on');
        set(h,'Enable','off');
        pause(0.1);
        object=generateHistory(object);        
        set(h,'Enable','on');
    end
DoneButton=popLabel(cb,'button');
set(DoneButton,'ButtonPushedFcn',@(~,~) delete(cb));


fit(cb);
locate(cb,'west',SourceFigure);
show(cb);
setWindowStyle(cb,'modal');
uiwait(cb.Figure);
figure(SourceFigure);

end