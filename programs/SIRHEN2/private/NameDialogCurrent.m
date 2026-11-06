function varargout=NameDialogCurrent(master)

cb=SMASH.MUI2.ComponentBox();
setName(cb,'Notes');

pushLabel(cb,'Measurement notes');
width=cb.LabelQueue.Width;
if nargin() < 1
    h=popLabel(cb,'message');
else
    width=sum(master);
    h=addMessage(cb,width);
    h.Text='Measurement notes';
end


set(h,'FontAngle','italic');
newRow(cb);

h=addEdit(cb,width);
set(h(1),'Text','Name:','FontWeight','bold');
set(h(2),'Tag','MeasurementName');
newRow(cb);

h=addTextarea(cb,width,6);
set(h(1),'Text','Comments:','FontWeight','bold');
set(h(2),'Tag','MeasurementComments');

fit(cb);

% manage output
if nargout() < 1
    show(cb);
else
    varargout{1}=cb;
end

end