function disableControl(control)

while true()
    try
        set([control.LinkOffsets control.ChannelSettings control.ChannelActions],...
            'Enable','off');
        break
    catch
        pause(0.01);        
    end
end

set([control.MeasurementName control.MeasurementComments],'Enable','off');

set([control.FFToptions],'Enable','off');
set([control.PartitionSettings control.AnalysisActions],'Enable','off');

end