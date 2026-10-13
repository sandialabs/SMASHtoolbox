function xyzSliderRelease(src, event, mainFigure, h_sliderStr, ...
    h_radio, h_edit, category, subcategory, varargin)

% In theory, I don't have to do all this. However, just in case MATLAB's
% listener functionality is a little buggy and the slider, edit box, and
% object somehow get out of sync, this should make sure they're all back on
% track upon the user's release of the slider.

% I'm also using this as the final update in updatePlotPredictionAnalysis

% Update: though it could be done in the main listener, I'm putting the
% reset handle stuff here to reduce the number of times it's called

if numel(varargin) == 1
    extraOption = get(varargin{1}, 'Value');
    optFlag = true;
else
    optFlag = false;
end

if numel(varargin) == 3
    resetHandle = varargin{1};
    resetType = varargin{2};
    resetValue = varargin{3};
    for ii = 1:length(resetHandle)
        set(resetHandle{ii}, resetType{ii}, resetValue{ii});
    end
end

updateEverything = true;

sliderVal = sliderExtract(event, h_sliderStr);
ind = [h_radio.Value];

obj = get(mainFigure, 'UserData');
newRot = obj.(category).([subcategory, 'Reference']);
newRot(ind) = newRot(ind) + sliderVal;
if optFlag
   updateFromEdit(mainFigure, newRot, category, subcategory, h_edit, ...
       updateEverything, extraOption);
   if extraOption && strcmpi(category, 'source') && strcmpi(subcategory, 'rotate')
       [db, ex] = createDlg(mainFigure, 'detectorDlg', 'dialog', false);
       if ex
           close(db.Handle);
       end
   end
else
    updateFromEdit(mainFigure, newRot, category, subcategory, h_edit, ...
        updateEverything);
end

end