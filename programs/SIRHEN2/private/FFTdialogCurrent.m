function data=FFTdialogCurrent(data,MainFigure)

cb=SMASH.MUI2.ComponentBox();
setName(cb,'FFT options');

list={'Hann' 'Hamming' 'Boxcar'};
index=find(strcmpi(data.FFTwindow,list));
pushLabel(cb,'Transform window');
width=cb.LabelQueue.Width;
hWindow=popLabel(cb,'listbox');
set(hWindow(1),'FontWeight','bold');
set(hWindow(2),'Items',list,'ValueIndex',index);
newRow(cb);

hNumFrequency=addEdit(cb,width);
set(hNumFrequency(1),'Text','Num. frequencies','FontWeight','bold');
temp=sprintf('%g %g',data.FFTbins);
message={};
message{end+1}='[min max] number of FFT frequencies.';
message{end+1}='Minimum achieved by zero padding.';
message{end+1}='Maximum enforced by interpolation.';
message=sprintf('%s ',message{:});
set(hNumFrequency(2),'Value',temp,'UserData',temp,...
    'ValueChangedFcn',@checkNumFrequency,'Tooltip',message)
    function checkNumFrequency(varargin)                       
        value=sscanf(hNumFrequency(2).Data,'%g');
        if isempty(value)
            set(hNumFrequency(2),'Data',get(hNumFrequency(2),'UserData'));
            return
        end
        if numel(value) < 2
            value(2)=inf;
        end
        value=round(sort(value(1:2)));
        if ~isfinite(value(1))
            set(hNumFrequency(2),'Data',get(hNumFrequency(2),'UserData'));
            return
        end
        value(1)=max(value(1),100);
        value(2)=max(value(2),2*value(1));        
        temp=sprintf('%g %g',value);                     
        set(hNumFrequency(2),'Data',temp,'UserData',temp);
    end
newRow(cb);

pushLabel(cb,'Show negative frequencies');
hNegFrequency=popLabel(cb,'checkbox');
if data.ShowNegativeFrequencies
    set(hNegFrequency(1),'Value',1);
end
newRow(cb);

pushLabel(cb,'Done','Cancel');
hButton=popLabel(cb,'buttons');
set(hButton(1),'ButtonPushedFcn',@done);
    function done(varargin)
        data.FFTwindow=hWindow(2).Value;
        data.FFTbins=sscanf(hNumFrequency(2).Value,'%g');
        data.ShowNegativeFrequencies=logical(hNegFrequency.Value);
        delete(cb);
    end
set(hButton(2),'ButtonPushedFcn',@cancel);
    function cancel(varargin)
        delete(cb);
    end

fit(cb);
locate(cb,'center',MainFigure);
setWindowStyle(cb,'modal');
show(cb);

uiwait(cb.Figure);
figure(MainFigure);

end