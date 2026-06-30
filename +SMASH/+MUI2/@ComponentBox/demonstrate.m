% demonstrate Create component box demo
%
% This *static* method creates a demonstration component box.
%    object=ComponentBox.demonstrate();
%
% The time needed to generate the demonstration box is printed in the
% command window for reference.  This time is systematically longer
% whenever the requested font has not already been used during the current
% MATLAB session or after display resolution change.
%
% See also ComponentBox, createExample, calfont
%
function object=demonstrate()

start=tic();

% create box
location=fileparts(mfilename('fullpath'));
[location,constructor]=fileparts(location);
constructor=constructor(2:end);
while any(location == '+')
    [location,namespace]=fileparts(location);
    constructor=sprintf('%s.%s',namespace(2:end),constructor);
end
object=feval(constructor);
setName(object,'Component box demo');

%
message{1}='This is a message block';
message{end+1}='Cyan region shows text boundaries';
message{end+1}='Left-side labels highlighted in yellow';
pushLabel(object,message);
width=object.LabelQueue.Width;
flushLabel(object);
h=addMessage(object,width,3);
h.Text=message;
h.BackgroundColor='c';
newRow(object);

pushLabel(object,'Push button','State button');
popLabel(object,'button',1,'push');
popLabel(object,'button',1,'state');
pushLabel(object,'Check box');
popLabel(object,'checkbox');
newRow(object);

setLabelPosition(object,'above');
pushLabel(object,'Edit:','Edit:');
popLabel(object,'edit',15);
setLabelPosition(object,'left');
h=popLabel(object,'edit',15);
h(1).BackgroundColor='y';
setLabelPosition(object,'above');
pushLabel(object,'Spinner field:');
popLabel(object,'spinner');
newRow(object);

setLabelPosition(object,'above');
pushLabel(object,'Drop down menu:');
h=popLabel(object,'dropdown');
set(h(end),'Items',{'A' 'B' 'C'});
setLabelPosition(object,'left');
pushLabel(object,'Drop:');
h=popLabel(object,'dropdown',10);
h(1).BackgroundColor='y';
newRow(object);

setLabelPosition(object,'above');
pushLabel(object,'List box:');
popLabel(object,'listbox',10);
pushLabel(object,'Button','Button');
popLabel(object,'button',2);
pushLabel(object,'Radio button');
width=object.LabelQueue.Width;
addRadio(object,width,3);
flushLabel(object);
pushLabel(object,'Toggle button');
width=object.LabelQueue.Width;
flushLabel(object);
addToggle(object,width,3);
newRow(object);

h=addTextarea(object,20,5);
h(1).Text='Text area:';
h=addImage(object,10,5);
h.Tooltip='Image block';
newRow(object);

h=addColorpicker(object,10);
h(1).Text='Color:';
h=addDatepicker(object,10);
h(1).Text='Date:';
h=addHyperlink(object,10);
h(1).Text='Hyperlink';
h(1).URL='www.mathworks.com';
newRow(object);

pushLabel(object,'Parameter','Value')
h=popLabel(object,'table');
h(end).Tooltip='Table block';
pushLabel(object,'Standard tree:');
h=popLabel(object,'tree',[],4);
uitreenode(h(end),'Text','Node 1');
uitreenode(h(end),'Text','Node 2');
uitreenode(h(end),'Text','Node 3');
uitreenode(h(end),'Text','Node 4');
pushLabel(object,'Checkbox tree:');
h=popLabel(object,'tree',[],4,'checkbox');
uitreenode(h(end),'Text','Node 1');
uitreenode(h(end),'Text','Node 2');
uitreenode(h(end),'Text','Node 3');
uitreenode(h(end),'Text','Node 4');

newRow(object);
pushLabel(object,'Slider:','Range:');
popLabel(object,'slider',20);
popLabel(object,'slider',20,'range');

% finish up
fit(object);
locate(object,'northeast');
show(object);

stop=toc(start);
if stop >= 1
    fprintf('Component box demo generated in %.3g s\n',stop);
else
    fprintf('Component box demo generated in %.3f s\n',stop);
end

end