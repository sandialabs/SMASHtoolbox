function varargout=AnalysisDialogCurrent(master)

cb=SMASH.MUI2.ComponentBox();
setName(cb,'Analysis');

settings={'Duration' 'Advance' 'Blocks' 'Overlap' 'Points' 'Skip'};
if (nargin() < 1)
    pushLabel(cb,settings);
    width1a=cb.LabelQueue.Width;
    flushLabel(cb);
    width1b=numel('1000.00');
else
    width1a=master(1);
    width1b=master(2);
end

actions={'Update spectrogram' 'Manage ROI' 'Select reference' ...
    'Generate history'};
pushLabel(cb,actions);
width2=cb.LabelQueue.Width;
flushLabel(cb);

views={'Full history' 'Velocity' 'Amplitude' 'Spectrogram overlay'};
pushLabel(cb,views);
width3=cb.LabelQueue.Width;
flushLabel(cb);

width=max([width1a+width1b width2 width3]);

h=addButton(cb,width);
set(h,'Text','FFT options','Tag','FFToptions');
newRow(cb);

rows=numel(settings);
h=addTable(cb,[width1a width1b],rows);
set(h(1),'Text','Partitioning','FontWeight','bold');
h(1).Position(3)=h(2).Position(1)+h(2).Position(3)-h(1).Position(1);
remove(cb,h(2));
data=cell(rows,2);
for n=1:rows
    data{n}=settings{n};
end
set(h(3),'Data',data,'Tag','PartitionSettings',...
    'ColumnEditable',[false true]);
newRow(cb);

rows=numel(actions);
h=addListbox(cb,width2,rows);
set(h(1),'Text','Actions','FontWeight','bold');
list=cell(rows,1);
for n=1:rows
    list{n}=actions{n};
end
set(h(2),'Items',list,'Tag','AnalysisActions',...
    'Tooltip','Double-click to perform action');
newRow(cb);

rows=numel(views);
h=addListbox(cb,width3,rows);
set(h(1),'Text','View','FontWeight','bold');
list=cell(rows,1);
for n=1:rows
    list{n}=views{n};
end
set(h(2),'Items',list,'Tag','ViewHistory','Enable','off',...
    'Tooltip','Double-click to perform action');

fit(cb);

% manage output
if nargout() < 1
    show(cb);
else
    varargout{1}=cb;
end

end