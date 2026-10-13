function xyzSliderListener(src, event, mainFigure, h_sliderStr, ...
    h_radio, h_edit, category, subcategory, varargin)

if ~isempty(varargin)
    extraOption = get(varargin{1}, 'Value');
    optFlag = true;
else
    optFlag = false;
end

updateEverything = false;

sliderVal = sliderExtract(event, h_sliderStr, varargin);
ind = [h_radio.Value];

obj = get(mainFigure, 'UserData');
newRot = obj.(category).([subcategory, 'Reference']);
newRot(ind) = newRot(ind) + sliderVal;
if optFlag
   updateFromEdit(mainFigure, newRot, category, subcategory, h_edit, ...
       updateEverything, extraOption);
else
    updateFromEdit(mainFigure, newRot, category, subcategory, h_edit, ...
        updateEverything);
end
end