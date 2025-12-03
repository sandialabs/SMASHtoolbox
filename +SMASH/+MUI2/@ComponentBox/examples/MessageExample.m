% MessageExample Component box example with a message block
% 
function MessageExample()

% import namespace

% create box
cb=ComponentBox();
setName(cb,'Message example');
setFont(cb,'',20);

% add and configure components
hm=addMessage(cb,20,1);  % one line of text with up to 20 characters
hm.Text='This is a message box';
newRow(cb);

hb=addButton(cb,10); % button fits 10 characters
hb.Text='Close';
hb.ButtonPushedFcn=@closeBox;
    function closeBox(varargin)        
        delete(cb);
    end

% finish up
fit(cb);
locate(cb);
show(cb);

uiwait(cb.Figure);


end