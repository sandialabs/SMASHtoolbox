% QuestionExample Component box example with a listbox block
function select=QuestionExample()

% import namespace

% create box
cb=ComponentBox();
setName(cb,'Question example');

% add and configure components
hl=addListbox(cb,20,5);
hl(1).Text='Which of these do you want?';
hl(1).FontWeight='bold';
N=10;
choice=cell(1,N);
for n=1:N
    choice{n}=sprintf('Option %d',n);
end
hl(2).Items=choice;
hl(2).Multiselect='on';

newRow(cb);

hb=addButton(cb,10); % button fits 10 characters
hb.Text='Done';
hb.ButtonPushedFcn=@closeBox;
select=[];
    function closeBox(varargin)
        select=hl(2).Value;
        delete(cb);
    end

% finish up
fit(cb);
locate(cb);
show(cb);

uiwait(cb.Figure);

end
