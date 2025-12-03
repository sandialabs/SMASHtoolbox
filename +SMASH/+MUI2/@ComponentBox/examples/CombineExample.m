% CombineExample Combine two component boxes with a plot
%
function [h,new]=CombineExample()

% import namespace

cb(1)=ComponentBox();
cb(2)=ComponentBox();

h=addDropdown(cb(1),10);
h(1).Text='Curve type:';
h(2).Items={'Line' 'Parabola' 'Sinusoid' 'Peak'};
h(2).Tag='CurveType';
newRow(cb(1));
h=addColorpicker(cb(1),10);
h(1).Text='Line color:';
h(2).Value='k';
h(2).Tag='Color';
newRow(cb(1));
h=addSpinner(cb(1),10);
h(1).Text='Line width:';
h(2).Value=1;
h(2).Limits=[0.5 20];
h(2).Step=0.5;
h(2).Tag='Width';

message{1}='* Fixed width font *';
message{end+1}='This tab does not alter the plot';
message{end+1}='Users can leave feedback below';
col=cellfun(@numel,message);
h=addMessage(cb(2),max(col),3);
h.Text=message;
newRow(cb(2));
h=addTextarea(cb(2),max(col),5);
h(1).Text='Feedback:';
h(2).Tag='Feedback';
newRow(cb(2));
h=addButton(cb(2),10);
h.Text='Submit';
h.Tag='Submit';

fit(cb);
[parent,new,fig,tg]=combine(cb,[],'hide');
fig.Name='Combine example';
tg.TabLocation='bottom';
tg.Children(1).Title='Plot';
tg.Children(2).Title='Notes';

ha=axes(parent(2),'Units','normalized','OuterPosition',[0 0 1 1],'Box','on',...
    'FontSize',cb(1).Font.Size);
xlabel(ha,'x');
ylabel(ha,'y');
h=line(ha);
h.Tag='Line';

h=guihandles(parent(1));

set(h.CurveType,'ValueChangedFcn',@selectCurve)
selectCurve();
    function selectCurve(varargin)
        x=linspace(-1,1,1000);
        switch h.CurveType.Value
            case 'Line'
                y=x;
            case 'Parabola'
                y=x.^2;
            case 'Sinusoid'
                y=cospi(2*x);
            case 'Peak'
                y=exp(-x.^2/(2*0.2^2));
        end
        set(h.Line,'XData',x,'YData',y);
    end

set(h.Color,'ValueChangedFcn',@changeColor)
changeColor();
    function changeColor(varargin)
        set(h.Line,'Color',h.Color.Value);
    end

set(h.Width,'ValueChangedFcn',@changeWidth)
changeWidth();
    function changeWidth(varargin)
        set(h.Line,'LineWidth',h.Width.Value);
    end

set(h.Submit,'ButtonPushedFcn',@submit)
    function submit(varargin)
        message=h.Feedback.Value;
        message=sprintf('\t%s\n',message{:});
        commandwindow();
        if isempty(strtrim(message))
            fprintf('No user feedback\n');
        else
            fprintf('User feedback:\n');
            fprintf('%s',message);
        end
    end

% 
delete(cb);

units=fig.Units;
fig.Units='normalized';
fig.Position=[1/6 1/6 4/6 4/6];
fig.Units=units;

figure(fig);

end