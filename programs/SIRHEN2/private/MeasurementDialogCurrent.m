function varargout=MeasurementDialogCurrent()

cb=SMASH.MUI2.ComponentBox();
setName(cb,'Measurement');

settings={'Wavelength' 'Offset' 'Bandwidth' 'Correction'};
pushLabel(cb,settings);
width1a=cb.LabelQueue.Width;
flushLabel(cb);
width1b=12;

actions={'Shift time base' 'Scale time base' 'Crop time base' ...
    'Calculate offset' 'Remove sinusoid' 'Show raw spectrogram' 'Show signal'};
pushLabel(cb,actions);
width2=cb.LabelQueue.Width;
flushLabel(cb);

h=addButton(cb,width2);
set(h,'Text','Load signal(s)','Tag','LoadChannel');
newRow(cb);

h=addListbox(cb,width2,3);
set(h(1),'Text','Channels','FontWeight','bold');
set(h(2),'Tag','ChannelList','Items',{});
newRow(cb);

rows=numel(settings);
h=addTable(cb,[width1a width1b],rows);
set(h(1),'Text','Settings','FontWeight','bold');
h(1).Position(3)=h(2).Position(1)+h(2).Position(3)-h(1).Position(1);
remove(cb,h(2));
data=cell(rows,2);
for n=1:rows
    data{n,1}=settings{n};
end
set(h(3),'Data',data,'Tag','ChannelSettings',...
    'ColumnEditable',[false true]);
newRow(cb);

pushLabel(cb,'Link offsets');
h=popLabel(cb,'checkbox');
set(h,'Tag','LinkOffsets');
newRow(cb);

h=addListbox(cb,width2,4); % first four actions are immediate visible
set(h(1),'Text','Actions','FontWeight','bold');
rows=numel(actions);
list=cell(rows,1);
for n=1:rows
    list{n}=actions{n};
end
set(h(2),'Tag','ChannelActions','Items',list,...
    'Tooltip','Double-click to perform action');

fit(cb);

% manage output
if nargout() < 1
    show(cb);
else
    varargout{1}=cb;
    varargout{2}=[width1a width1b];
end

end