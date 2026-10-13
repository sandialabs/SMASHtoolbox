% NoteExample Component box example with text area block
function final=NoteExample(original)

if nargin() < 1
    original='';
end

% import namespace

% create box
cb=ComponentBox();
setName(cb,'Note example');

setFont(cb,'',14);

% add and configure components
ht=addTextarea(cb,40,10);  % one line of text with up to 15 characters
ht(1).Text='Notes:';
ht(1).FontWeight='bold';
ht(2).Value=original;
newRow(cb);

hb=addButton(cb,10); % button fits 10 characters
hb.Text='Close';
hb.ButtonPushedFcn=@closeBox;
final=[];
    function closeBox(varargin)
        final=ht(2).Value;
        fig=ancestor(varargin{1},'figure');
        delete(fig);
    end

% finish up
fit(cb);
locate(cb);
show(cb);

uiwait(cb.Figure);

end