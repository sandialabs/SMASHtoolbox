function func = EllipseFittingGUI(recordData)
% ELLIPSEFITTINGGUI - Generates a GUI for user to update Ellipse parameters
%                   - Takes in a Data Record and displays the current
%                     ellipse parameters and produces a smaller version of 
%                     quadrature plot from ReadEditRecordGUI. The user can
%                     then update the ellipse params or use two ellipse
%                     fitting routines. (The code for the ellipse fitting
%                     routines have not yet been provided.

MainFig = findall(0,'Type','figure','Tag','PointVISAR');
MainPos = get(MainFig,'Position');

theUserData = populateFigureUserData(recordData);

% Create the main figure
% h = figure('Tag', 'ellipseGUI', ...
%    'Units', 'pixels', ...
%    'Visible', 'off', ...
%    'Position', [632 315 540 410], ...
%    'MenuBar', 'none', ...
%    'ToolBar', 'none', ...
%    'NumberTitle', 'off', ...
%    'Name', 'Ellipse Fitting', ...
%    'Resize', 'off', ...
%    'UserData', theUserData, ...
%    'WindowStyle', 'normal');

h = MinimalFigure('Tag', 'ellipseGUI', 'NumberTitle', 'off', ...
    'Units', 'pixels', 'Position', [632 315 540 410], ...
    'Name', 'Ellipse Fitting', 'Resize', 'off', ...
    'UserData', theUserData);

movegui(h,'center');
       
% Create a panel that will span the entire figure
mainEllipsePanel = uipanel('Title', '', ...
                           'Units', 'pixels', ...
                           'Parent', h, ...
                           'Tag', 'ellipseGUIMainPanel', ...
                           'Position', [0 0 540 410]);

% Create a sub-panel that will contain all labels, textfields, and
% checkboxes associated with the ellipse parameters
ellipseParamPanel = uipanel('Title', '', ...
                            'Units', 'pixels', ...
                            'Parent', mainEllipsePanel, ...
                            'FontUnits', 'pixels', ...
                            'FontSize', 12, ...
                            'Position', [10 150 195 204], ...
                            'BorderType', 'etchedin', ...
                            'ForegroundColor', 'white', ...
                            'Tag', 'ellipseGUIParamPanel');
                        
% Create a sub-panel that will contain the quadrature plot
ellipseFigurePanel = uipanel('Title', '', ...
                             'Units', 'pixels', ...
                             'Parent', mainEllipsePanel, ...
                             'FontUnits', 'pixels', ...
                             'FontSize', 12, ...
                             'Position', [220 50 300 300], ...
                             'BorderType', 'etchedin', ...
                             'BackgroundColor', 'white', ...
                             'ForegroundColor', 'black', ...
                             'Tag', 'ellipseGUIFigurePanel');

% Create a sub-panel will contain the push buttons for the ellipse fitting
% routines.
ellipseFigureButtonPanel = uipanel('Title', '', ...
                                   'Units', 'pixels', ...
                                   'FontUnits', 'pixels', ...
                                   'Parent', mainEllipsePanel, ...
                                   'FontSize', 12, ...
                                   'Position', [45 50 85 100], ...
                                   'BorderType', 'etchedin', ...
                                   'ForegroundColor', 'white', ...
                                   'Tag', 'ellipseGuiFigureButtonPanel');

% Create a sub-panel that will contain the push buttons to either apply the
% changes, or cancel out and return to the ReadEditRecordGUI
ellipseGUIControlButtonPanel = uipanel('Title', '', ...
                                       'Units', 'pixels', ...
                                       'Parent', mainEllipsePanel, ...
                                       'FontUnits', 'pixels', ...
                                       'FontSize', 12, ...
                                       'Position', [357 5 163 33], ...
                                       'BorderType', 'etchedin', ...
                                       'ForegroundColor', 'white', ...
                                       'Tag', 'ellipseGuiControlButtonPanel');
% Create the "OK" button
okButton = uicontrol('Style', 'pushbutton', ...
                     'Parent', ellipseGUIControlButtonPanel, ...
                     'Units', 'pixels', ...
                     'String', 'OK', ...
                     'UserData', 'OK', ...
                     'FontUnits', 'pixels', ...
                     'FontSize', 15, ...
                     'HorizontalAlignment', 'center', ...
                     'Position', [5 5 75 25], ...
                     'KeyPressFcn',@doControlKeyPress , ...
                     'Callback', {@ExitEllipseGUI, 'OK'}, ...
                     'Tag', 'ellipseGUIOkButon');
                     
% Create the "Cancel" button
cancelButton = uicontrol('Style', 'pushbutton', ...
                         'Parent', ellipseGUIControlButtonPanel, ...
                         'Units', 'pixels', ...
                         'String', 'Cancel', ...
                         'UserData', 'Cancel', ...
                         'FontUnits', 'pixels', ...
                         'FontSize', 15, ...
                         'HorizontalAlignment', 'center', ...
                         'Position', [85 5 75 25], ...
                         'KeyPressFcn',@doControlKeyPress , ...
                         'Callback', {@ExitEllipseGUI, 'Cancel'}, ...
                         'Tag', 'ellipseGUICancelButon');

% Create the "Optimize" button                               
optimizeButton = uicontrol('Style', 'pushbutton', ...
                           'Parent', ellipseFigureButtonPanel, ...
                           'Units', 'pixels', ...
                           'String', 'Optimize', ...
                           'Callback', @button_Callback, ...
                           'FontUnits', 'pixels', ...
                           'FontSize', 15, ...
                           'HorizontalAlignment', 'center', ...
                           'Position', [5 5 75 25], ...
                           'Tag', 'ellipseGUIOptimizeButton');

% Create the "Guess" button                           
guessButton = uicontrol('Style', 'pushbutton', ...
                        'Parent', ellipseFigureButtonPanel, ...
                        'Units', 'pixels', ...
                        'String', 'Guess', ...
                        'Callback', @button_Callback, ...
                        'FontUnits', 'pixels', ...
                        'FontSize', 15, ...
                        'HorizontalAlignment', 'center', ...
                        'Position', [5 65 75 25], ...
                        'Tag', 'ellipseGUIGuessButton');
                    
% Create the "Center" button                           
centerButton = uicontrol(....
    'Style', 'pushbutton', ...
    'Enable','on',...
    'Parent', ellipseFigureButtonPanel, ...
    'Units', 'pixels', ...
    'String', 'Center', ...
    'Callback', @button_Callback, ...
    'FontUnits', 'pixels', ...
    'FontSize', 15, ...
    'HorizontalAlignment', 'center', ...
    'Position', [5 35 75 25], ...
    'Tag', 'ellipseGUICenterButton');

% Create a sub-panel for the EllipseParam panel, that contains the label,
% textfield, and checkbox for the x0 parameter
x0Panel = uipanel('Parent', ellipseParamPanel, ...
                  'Title', '', ...
                  'Units', 'pixels', ...
                  'FontUnits', 'pixels', ...
                  'FontSize', 12, ...
                  'Position', [5 166 185 33], ...
                  'Units', 'pixels', ...
                  'BorderType', 'etchedin', ...
                  'Tag', 'ellipseGUIX0Panel');
              
% Create a sub-panel for the EllipseParam panel, that contains the label,
% textfield, and checkbox for the y0 parameter           
y0Panel = uipanel('Parent', ellipseParamPanel, ...
                  'Title', '', ...
                  'Units', 'pixels', ...
                  'FontUnits', 'pixels', ...
                  'FontSize', 12, ...
                  'Position', [5 126 185 33], ...
                  'Units', 'pixels', ...
                  'BorderType', 'etchedin', ...
                  'Tag', 'ellipseGUIY0Panel');

% Create a sub-panel for the EllipseParam panel, that contains the label,
% textfield, and checkbox for the Lx parameter
LxPanel = uipanel('Parent', ellipseParamPanel, ...
                  'Title', '', ...
                  'Units', 'pixels', ...
                  'FontUnits', 'pixels', ...
                  'FontSize', 12, ...
                  'Position', [5 86 185 33], ...
                  'Units', 'pixels', ...
                  'BorderType', 'etchedin', ...
                  'Tag', 'ellipseGUILxPanel');

% Create a sub-panel for the EllipseParam panel, that contains the label,
% textfield, and checkbox for the Ly parameter
LyPanel = uipanel('Parent', ellipseParamPanel, ...
                  'Title', '', ...
                  'Units', 'pixels', ...
                  'FontUnits', 'pixels', ...
                  'FontSize', 12, ...
                  'Position', [5 46 185 33], ...
                  'Units', 'pixels', ...
                  'BorderType', 'etchedin', ...
                  'Tag', 'ellipseGUILyPanel');

% Create a sub-panel for the EllipseParam panel, that contains the label,
% textfield, and checkbox for the Phi parameter
phiPanel = uipanel('Parent', ellipseParamPanel, ...
                  'Title', '', ...
                  'Units', 'pixels', ...
                  'FontUnits', 'pixels', ...
                  'FontSize', 12, ...
                  'Position', [5 6 185 33], ...
                  'Units', 'pixels', ...
                  'BorderType', 'etchedin', ...
                  'Tag', 'ellipseGUIPhiPanel');

% Create the "X0" label
x0Label = uicontrol('Style', 'text', ...
                    'Units', 'pixels', ...
                    'Parent', x0Panel, ...
                    'String', 'X0', ...
                    'FontUnits', 'pixels', ...
                    'FontSize', 15, ...
                    'HorizontalAlignment', 'center', ...
                    'Position', [5 5 50 25], ...
                    'Tag', 'ellipseGUIX0Label');
                    
% Create the "Y0" label
y0Label = uicontrol('Style', 'text', ...
                    'Units', 'pixels', ...
                    'Parent', y0Panel, ...
                    'String', 'Y0', ...
                    'FontUnits', 'pixels', ...
                    'FontSize', 15, ...
                    'HorizontalAlignment', 'center', ...
                    'Position', [5 5 50 25], ...
                    'Tag', 'ellipseGUIY0Label');
                    
% Create the "Lx" label
LxLabel = uicontrol('Style', 'text', ...
                    'Units', 'pixels', ...
                    'Parent', LxPanel, ...
                    'String', 'Lx', ...
                    'FontUnits', 'pixels', ...
                    'FontSize', 15, ...
                    'HorizontalAlignment', 'center', ...
                    'Position', [5 5 50 25], ...
                    'Tag', 'ellipseGUILxLabel');
                   
% Create the "Ly" label
LyLabel = uicontrol('Style', 'text', ...
                    'Units', 'pixels', ...
                    'Parent', LyPanel, ...
                    'String', 'Ly', ...
                    'FontUnits', 'pixels', ...
                    'FontSize', 15, ...
                    'HorizontalAlignment', 'center', ...
                    'Position', [5 5 50 25], ...
                    'Tag', 'ellipseGUILyLabel');
                    
% Create the "Phi" label

phiLabel = uicontrol('Style', 'text', ...
                    'Units', 'pixels', ...
                    'Parent', phiPanel, ...
                    'String', 'Epsilon', ...
                    'FontUnits', 'pixels', ...
                    'FontSize', 15, ...
                    'HorizontalAlignment', 'center', ...
                    'Position', [5 5 50 25], ...
                    'Tag', 'ellipseGUIPhiLabel');
                    
% Create the x0 textfield
x0TextField = uicontrol('Style', 'edit', ...
                        'Units', 'pixels', ...
                        'Parent', x0Panel, ...
                        'String', '', ...
                        'FontUnits', 'pixels', ...
                        'FontSize', 15, ...
                        'HorizontalAlignment', 'left', ...
                        'Position', [60 5 70 25], ...
                        'Callback', @textbox_Callback, ...
                        'BackgroundColor', [1 1 1], ...
                        'Tag', 'ellipseGUIx0TextField');
                        
% Create the y0 textfield
y0TextField = uicontrol('Style', 'edit', ...
                        'Units', 'pixels', ...
                        'Parent', y0Panel, ...
                        'String', '', ...
                        'FontUnits', 'pixels', ...
                        'FontSize', 15, ...
                        'HorizontalAlignment', 'left', ...
                        'Position', [60 5 70 25], ...
                        'Callback', @textbox_Callback, ...
                        'Tag', 'ellipseGUIy0TextField', ...
                        'BackgroundColor', [1 1 1]);
                        
% Create the Lx textfield
LxTextField = uicontrol('Style', 'edit', ...
                        'Units', 'pixels', ...
                        'Parent', LxPanel, ...
                        'String', '', ...
                        'FontUnits', 'pixels', ...
                        'FontSize', 15, ...
                        'HorizontalAlignment', 'left', ...
                        'Position', [60 5 70 25], ...
                        'Callback', @textbox_Callback, ...
                        'Tag', 'ellipseGUILxTextField', ...
                        'BackgroundColor', [1 1 1]);
                        
% Create the Ly textfield
LyTextField = uicontrol('Style', 'edit', ...
                        'Units', 'pixels', ...
                        'Parent', LyPanel, ...
                        'String', '', ...
                        'FontUnits', 'pixels', ...
                        'FontSize', 15, ...
                        'HorizontalAlignment', 'left', ...
                        'Position', [60 5 70 25], ...
                        'Callback', @textbox_Callback, ...
                        'Tag', 'ellipseGUILyTextField', ...
                        'BackgroundColor', [1 1 1]);
                        
% Create the Phi textfield
phiTextField = uicontrol('Style', 'edit', ...
                        'Units', 'pixels', ...
                        'Parent', phiPanel, ...
                        'String', '', ...
                        'FontUnits', 'pixels', ...
                        'FontSize', 15, ...
                        'HorizontalAlignment', 'left', ...
                        'Position', [60 5 70 25], ...
                        'Callback', @textbox_Callback, ...
                        'Tag', 'ellipseGUIphiTextField', ...
                        'BackgroundColor', [1 1 1]);
                        
% Create the x0 checkbox
x0Checkbox = uicontrol('Style', 'checkbox', ...
                       'Units', 'pixels', ...
                       'Parent', x0Panel, ...
                       'Callback', @checkbox_Callback, ...
                       'String', 'Fix', ...
                       'HorizontalAlignment', 'center', ...
                       'FontUnits', 'pixels', ...
                       'FontSize', 15, ...
                       'Tag', 'ellipseGUIx0Checkbox', ...
                       'Position', [135 5 45 25]);
                   
% Create the y0 checkbox
y0Checkbox = uicontrol('Style', 'checkbox', ...
                       'Units', 'pixels', ...
                       'Parent', y0Panel, ...
                       'Callback', @checkbox_Callback, ...
                       'String', 'Fix', ...
                       'HorizontalAlignment', 'center', ...
                       'FontUnits', 'pixels', ...
                       'FontSize', 15, ...
                       'Tag', 'ellipseGUIy0Checkbox', ...
                       'Position', [135 5 45 25]);
                       
% Create the Lx checkbox
LxCheckbox = uicontrol('Style', 'checkbox', ...
                       'Units', 'pixels', ...
                       'Parent', LxPanel, ...
                       'Callback', @checkbox_Callback, ...
                       'String', 'Fix', ...
                       'HorizontalAlignment', 'center', ...
                       'FontUnits', 'pixels', ...
                       'FontSize', 15, ...
                       'Tag', 'ellipseGUILxCheckbox', ...
                       'Position', [135 5 45 25]);
                       
% Create the Ly checkbox
LyCheckbox = uicontrol('Style', 'checkbox', ...
                       'Units', 'pixels', ...
                       'Parent', LyPanel, ...
                       'Callback', @checkbox_Callback, ...
                       'String', 'Fix', ...
                       'HorizontalAlignment', 'center', ...
                       'FontUnits', 'pixels', ...
                       'FontSize', 15, ...
                       'Tag', 'ellipseGUILyCheckbox', ...
                       'Position', [135 5 45 25]);
                       
% Create the Phi checkbox
phiCheckbox = uicontrol('Style', 'checkbox', ...
                       'Units', 'pixels', ...
                       'Parent', phiPanel, ...
                       'Callback', @checkbox_Callback, ...
                       'String', 'Fix', ...
                       'HorizontalAlignment', 'center', ...
                       'FontUnits', 'pixels', ...
                       'FontSize', 15, ...
                       'Tag', 'ellipseGUIphiCheckbox', ...
                       'Position', [135 5 45 25]);
                   
% Fill in ellipse values
% hData = get(h, 'UserData');

% Display the GUI
set(h,'Visible','on');

% ellipseParams = theUserData{1,3};

% set(x0TextField, 'String', ellipseParams(1));
% set(y0TextField, 'String', ellipseParams(2));
% set(LxTextField, 'String', ellipseParams(3));
% set(LyTextField, 'String', ellipseParams(4));
% set(phiTextField, 'String', ellipseParams(5));

% Create the axes for the quadrature plot
axisHandle = axes('Parent', ellipseFigurePanel, 'Tag', ...
    'ellipseFittingQuadraturePlot', 'DataAspectRatioMode', 'manual', ...
    'DataAspectRatio',[1 1 1], 'PlotBoxAspectRatioMode', 'manual', ...
    'PlotBoxAspectRatio',[1 1 1]);
% axisHandle = axes('Parent', ellipseFigurePanel, 'Tag', 'ellipseFittingQuadraturePlot');
xlabel('D1');
ylabel('D2');
title('Quadrature Plot','FontWeight','bold');
% axis equal
grid on

% Create the quadrature line for the plot
line(0,0,'Color',[0 0 1],...
    'Tag','ellipseFittingQuadratureLine','Visible','off');
% ellipseFittingQuadratureLine = findobj(gcf, 'Tag', 'ellipseFittingQuadratureLine');
% set(ellipseFittingQuadratureLine, 'XData', theUserData{1,5}, 'YData', ...
%    theUserData{1,6});
% set(ellipseFittingQuadratureLine, 'Visible', 'on');

% EllipsePlot(ellipseParams, 'overwrite', axisHandle);

% axis equal
axis tight

% movegui(h, 'center');
drawnow;
updateEllipseFittingGUI
    
% This dialog needs to block until the user has clicked OK or Cancel
 uiwait(h);
    
% check if user clicked OK or Cancel
if ishandle(h)
    userData = get(h, 'UserData');
    closeAction = userData{1,4};
    if strcmp(closeAction, 'OK')
        % Do something here
        userData{1,1}.Ellipse = userData{1,3};
        userData{1,1}.EllipseFixed = userData{1,2};
        userData{1,1}.EllipseFit = 'true';
        func = userData{1,1};
    elseif strcmp(closeAction, 'Cancel')
        func = recordData;
    end
    delete(h);
end                       

function button_Callback(hObject, eventdata, handles)
% BUTTON_CALLBACK   Callback executed when a user clicks on one of buttons.

buttonTag = get(hObject, 'Tag');    % Get the tag for the button

theFig = findobj('Tag', 'ellipseGUI');
figData = get(theFig, 'UserData');
ellipseParams = figData{1,3};
fixedParams = figData{1,2};
ellipseD1 = figData{1,5};
ellipseD2 = figData{1,6};

% Based on which button was clicked, call the approriate function
switch buttonTag
    case 'ellipseGUICenterButton'
        % Need to enable zooming on the axis to fully implement
        % the functionality of the center button
        theXLim = get(gca, 'XLim');
        theYLim = get(gca, 'YLim');
        
        % Average all values in D1 within the bounds of the limits
        ii=(ellipseD1>theXLim(1)) & (ellipseD1<theXLim(2));
        newX0=mean(ellipseD1(ii));
        %runningSum = 0;
        %numOfIndicies = 0;
        %for ii=1:numel(ellipseD1)
        %    if ellipseD1(ii) > theXLim(1) & ellipseD1(ii) < theXLim(2)
        %        runningSum = runningSum + ellipseD1(ii);
        %        numOfIndicies = numOfIndicies + 1;
        %    end
        %end
        %newX0 = runningSum / numOfIndicies;
        
        % Average all values in D2 within the bounds of the limits
        ii=(ellipseD2>theYLim(1)) & (ellipseD2<theYLim(2));
        newY0=mean(ellipseD2(ii));
        %runningSum = 0;
        %numOfIndicies = 0;
        %for ii=1:numel(ellipseD2)
        %    if ellipseD2(ii) > theYLim(1) & ellipseD2(ii) < theYLim(2)
        %        runningSum = runningSum + ellipseD2(ii);
        %        numOfIndicies = numOfIndicies + 1;
        %    end
        %end
        %newY0 = runningSum / numOfIndicies;
        
        % Check if X0 and Y0 check boxes are currently selected
        if fixedParams(1) == 1 | fixedParams(2) == 1
           
            % Warn the user that to center, X0 and Y0 cannot be fixed
            prompt{1} = 'To use center, X0 and Y0 cannot be fixed. Clear fixed and continue?';
            answer = questdlg(prompt, 'Clear Fixed X0 and Y0 Parameters');
            
            % If they select Ok
            if strcmp(lower(answer),'yes')
                % Clear the fixed parameters, update the FigureData
                fixedParams(1) = 0;
                fixedParams(2) = 0;
                
                % Set the new X0 and Y0 
                ellipseParams(1) = newX0;
                ellipseParams(2) = newY0;
                
                % Update the userdata
                figData{1,2} = fixedParams;
                figData{1,3} = ellipseParams;
                set(theFig, 'UserData', figData);
            end
        else
            ellipseParams(1) = newX0;
            ellipseParams(2) = newY0;
            
            % Update the userdata
            figData{1,3} = ellipseParams;
            set(theFig, 'UserData', figData);
        end
        
    case 'ellipseGUIGuessButton'
        % Check if any of the fixed radio buttons are currently selected
        if sum(fixedParams) ~= 0
            % One or mored of the fix radio buttons are selected
            
            % Warn the user that to Guess fix params will be unfixed
            prompt{1} = 'To guess all fixed parameters will be cleared?';
            answer = questdlg(prompt,'Clear Fixed Parameters');
            
            % If they select OK
            if strcmp(lower(answer),'yes')
                % Clear the fixed parameters, update the FigureData
                fixedParams = zeros(1,5);
                figData{1,2} = fixedParams;
                
                % Call the ellipse fitting routine to get ellipse parameters
                newEllipseParams = DirectEllipseFit(ellipseD1, ellipseD2);
                
                % Set the new parameters
                figData{1,3} = newEllipseParams;
                set(theFig, 'UserData', figData);
            end
        else
            % Call the ellipse fitting routine to get ellipse parameters
            newEllipseParams = DirectEllipseFit(ellipseD1, ellipseD2);
                
            % Set the new parameters
            figData{1,3} = newEllipseParams;
            set(theFig, 'UserData', figData);
        end
        
    case 'ellipseGUIOptimizeButton'
        optimizedEllipseParams = IterativeEllipseFit(ellipseD1, ...
            ellipseD2, ellipseParams, fixedParams);
        
        figData{1,3} = optimizedEllipseParams;
        set(theFig, 'UserData', figData);
        
    otherwise
        error('ERROR: EllipseFitGUI:button_Callback - Unknown button!');
end

updateEllipseFittingGUI;

function textbox_Callback(hObject, eventdata, handles)
% TEXTBOX_CALLBACK  Callback executed when a user changes a value in one
% of the textfields. This callback is called after the user clicks another
% component on the gui.

textboxTag = get(hObject, 'Tag');   % Get the tag for the textfield
ellipseIndex = -1;                  % Set the index out of range to start

% Based on which textfield was edited, set the array index that corresponds
% to that ellipse value
switch textboxTag
    case 'ellipseGUIx0TextField'
        ellipseIndex = 1;
        %disp('X0 text');
    case 'ellipseGUIy0TextField'
        ellipseIndex = 2;
        %disp('Y0 text');
    case 'ellipseGUILxTextField'
        ellipseIndex = 3;
        %disp('Lx text');
    case 'ellipseGUILyTextField'
        ellipseIndex = 4;
        %disp('Ly text');
    case 'ellipseGUIphiTextField'
        ellipseIndex = 5;
        %disp('Phi text');
    otherwise
        error('ERROR: EllipseFitGUI:textbox_Callback - Unknown textbox!');
end

% Get the value out of the text field and check that it is a number.
% If it is not display an error dialog
user_entry = str2double(get(hObject,'string'));
if isnan(user_entry)
    errordlg('You must enter a numeric value','Bad Input','modal')
end

% Update the local version of the ellipse, and call VisarAnalysis
ellipseGUIHandle = findobj('Tag', 'ellipseGUI');
theRecordData = get(ellipseGUIHandle, 'UserData');
theEllipseData = theRecordData{1,3};
if ~isnan(user_entry)
    theEllipseData(ellipseIndex) = user_entry;
end

theRecordData{1,3} = theEllipseData;
set(ellipseGUIHandle, 'UserData', theRecordData);

% replotQuadrature(theRecordData);
updateEllipseFittingGUI;


function checkbox_Callback(hObject, eventdata, handles)
% CHECKBOX_CALLBACK Callback executed when a users selects/unselects one of
% the checkboxes

checkboxTag = get(hObject, 'Tag');  % Get the tag for the checkboxed

% Based on the checkbox, set the tag for the textfield that should be
% disabled
switch checkboxTag
    case 'ellipseGUIx0Checkbox'
        checkParamIndex = 1;
    case 'ellipseGUIy0Checkbox'
        checkParamIndex = 2;
    case 'ellipseGUILxCheckbox'
        checkParamIndex = 3;
    case 'ellipseGUILyCheckbox'
        checkParamIndex = 4;
    case 'ellipseGUIphiCheckbox'
        checkParamIndex = 5;
    otherwise
        error('ERROR: EllipseFitGUI:checkbox_Callback - Unknown checkbox!');
end

theFig = findobj('Tag', 'ellipseGUI');
figData = get(theFig, 'UserData');
checkParams = figData{1,2};

% Check whether the check box was selected or unselected
if (get(hObject,'Value') == get(hObject,'Max'))
    checkParams(checkParamIndex) = 1;
else
    checkParams(checkParamIndex) = 0;
end

figData{1,2} = checkParams;
set(theFig, 'UserData', figData);
updateEllipseFittingGUI

function replotQuadrature(userData)
% REPLOTQUADRATURE Updates the quadrature plot, should be called after a 
% user has made a change to one of the ellipse settings or clicked one of
% the ellipse fitting buttons

% QuadratureLine = findobj(gcf, 'Tag', 'QuadratureLine');
% set(QuadratureLine, 'XData', userData.D{1,1}, 'YData', userData.D{1,2});
% set(QuadratureLine, 'Visible', 'on');
% axis equal
% axis tight

% QuadraturePlot = findobj(gca, 'Tag', 'QuadraturePlot');
% refresh(QuadraturePlot);
% drawnow;

function updateEllipseFittingGUI()
% UPDATEELLIPSEFITTINGGUI   Updates the gui based on the current UserData

theFigure = findobj('Tag', 'ellipseGUI');

theUserData = get(theFigure, 'UserData');   % Get the UserData
theRecordData = theUserData{1,1};

% Update the textfields
theEllipseParams = theUserData{1,3};

x0TextField = findobj('Tag', 'ellipseGUIx0TextField');
set(x0TextField, 'String', theEllipseParams(1));

y0TextField = findobj('Tag', 'ellipseGUIy0TextField');
set(y0TextField, 'String', theEllipseParams(2));

LxTextField = findobj('Tag', 'ellipseGUILxTextField');
set(LxTextField, 'String', theEllipseParams(3));

LyTextField = findobj('Tag', 'ellipseGUILyTextField');
set(LyTextField, 'String', theEllipseParams(4));

phiTextField = findobj('Tag', 'ellipseGUIphiTextField');
set(phiTextField, 'String', theEllipseParams(5));

% Update the checkboxes
theFixedParams = theUserData{1,2};
for ii=1:5
    switch ii
        case 1
            textFieldTag = 'ellipseGUIx0TextField';
            checkBoxTag = 'ellipseGUIx0Checkbox';
        case 2
            textFieldTag = 'ellipseGUIy0TextField';
            checkBoxTag = 'ellipseGUIy0Checkbox';
        case 3
            textFieldTag = 'ellipseGUILxTextField';
            checkBoxTag = 'ellipseGUILxCheckbox';
        case 4
            textFieldTag = 'ellipseGUILyTextField';
            checkBoxTag = 'ellipseGUILyCheckbox';
        case 5
            textFieldTag = 'ellipseGUIphiTextField';
            checkBoxTag = 'ellipseGUIphiCheckbox';
        otherwise
            error('ERROR: EllipseFitGUI:UpdateEllipseFittingGUI - Unknown checkbox!');
    end
    
    % Find the handle for the textfield associated with this text box
    textFieldHandle = findobj('Tag', textFieldTag);
    checkBoxHandle = findobj('Tag', checkBoxTag);
    
    checkBoxMaxValue = get(checkBoxHandle, 'Max');
    checkBoxMinValue = get(checkBoxHandle, 'Min');
    
    % Check whether the check box is selected or unselected
    if theFixedParams(ii) == 0
        set(textFieldHandle, 'Enable', 'on');  % Not selected
        set(checkBoxHandle, 'Value', checkBoxMinValue);
    elseif theFixedParams(ii) == 1
        set(textFieldHandle, 'Enable', 'off'); % Is unselected
        set(checkBoxHandle, 'Value', checkBoxMaxValue);
    else
        error('ERROR: EllipseFitGUI:UpdateEllipseFittingGUI - Fixed param other than 0 or 1');    
    end
end

% Call VisarAnalysis
% theRecordData = VisarAnalysis(theRecordData, 'QuadratureSignals', ...
%    'Velocity');

theUserData{1,5} = theRecordData.D{1,1};
theUserData{1,6} = theRecordData.D{1,2};

% Update the plot
ellipseFittingQuadratureLine = findobj(gcf, 'Tag', 'ellipseFittingQuadratureLine');
set(ellipseFittingQuadratureLine, 'XData', theUserData{1,5}, 'YData', theUserData{1,6});
set(ellipseFittingQuadratureLine, 'Visible', 'on');

EllipsePlot(theEllipseParams, 'overwrite');

axis equal
axis tight


function ExitEllipseGUI(obj, event, arg1)
% store which button, OK or Cancel, was clicked
theUserData = get(gcbf, 'UserData');
theUserData{1,4} = arg1;
set(gcbf, 'UserData', theUserData);
    
% don't do a close here.  It will cause the list handles to become
% invalid.  The data will not be able to be retrieved from the lists.
% Do a uiresume so that the constructor method will wake up,
% fetch the new values, update the VisarData, and then return.
uiresume(gcbf);

    
function doFigureKeyPress(obj, evd)
switch(evd.Key)
 case {'return','space'}
  set(gcbf,'UserData','OK');
  uiresume(gcbf);
 case {'escape'}
  set(gcbf,'UserData','Cancel');
  uiresume(gcbf);
end


function doControlKeyPress(obj, evd)
switch(evd.Key)
 case {'return'}
  if ~strcmp(get(obj,'UserData'),'Cancel')
      set(gcbf,'UserData','OK');
      uiresume(gcbf);
  else
      set(gcbf,'UserData','Cancel');
      uiresume(gcbf);
  end
 case 'escape'
      set(gcbf,'UserData','Cancel');
      uiresume(gcbf);
end

% function paramValues getEllipseParameters()
%   GETELLIPSEPARAMETERS    Returns an array with the all current values
%                           from the ellipse parameter text boxes of the 
%                           GUI.
% paramValues(1) = 

function populatedData = populateFigureUserData(recordData)
%   POPULATEFIGUREUSERDATA  Returns a cell array that will be used for 
%                           the UserData of the figure. The first cell 
%                           contains the recordData passed in, the second
%                           contains an array representing the current
%                           values of the fixed checkboxes and the third
%                           contains an array representing the current
%                           ellipse parameters.
populatedData{1,1} = recordData;
populatedData{1,2} = recordData.EllipseFixed;
populatedData{1,3} = recordData.Ellipse;
populatedData{1,4} = 'NULL';
populatedData{1,5} = recordData.D{1,1};
populatedData{1,6} = recordData.D{1,2};
