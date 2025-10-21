function sliderVal = sliderExtract(event, h_sliderStr, varargin)

sliderVal = event.Value; % this is necessary for listener behavior
str = num2str(sliderVal);
if sliderVal > 0 && nargin < 3
    str = ['+', str];
end
set(h_sliderStr, 'Value', str);

end