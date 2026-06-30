function out=showBytes(value)

units={'bytes' 'kilobytes' 'megabytes' 'gigabytes' 'terabytes'};
for n=1:numel(units)
    if value < 1024
        break
    end
    value=value/1024;
end

if n == 1
    out=sprintf('%d %s',value,units{n});
elseif value < 10
    out=sprintf('%.2f %s',value,units{n});
elseif value < 100
    out=sprintf('%.1f %s',value,units{n});
else
    out=sprintf('%.0f %s',value,units{n});
end

end