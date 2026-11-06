% Dynamic version of DoubleInputDlg
%
% Created 9/2023 by Nathan Brown from DoubleInputDlg

function DoubleInputDlg_dynamic(prompt,title,fig,fieldName)

% input parsing

record = get(fig, 'UserData');
default = record.(fieldName);
sigfigs = 6;

% prepare default values for inputdlg
NumDefault=numel(default);
for ii=1:length(prompt)
    if ii>NumDefault
        DefaultInput{ii}='';
        continue
    end    
    temp=ExtractData(default,ii);
    DefaultInput{ii}=sscanf(FixedG(temp,sigfigs),'%s');
end

% make input dlg

db = SMASH.MUI.Dialog;
set(db.Handle, 'Tag', 'DoubleInputDlg_dynamic');
db.Name = title;
h = cell(1,length(prompt));
movegui(db.Handle, 'west');
pos = get(db.Handle, 'position');
pos(3) = 200;
set(fig, 'units', 'pixels');
bigFigPos = get(fig, 'Position');
set(fig, 'units', 'normalized');
pos(1) = bigFigPos(1);
set(db.Handle, 'position', pos);
for ii = 1:length(prompt)
    h{ii} = addblock(db, 'edit', prompt{ii});
    set(h{ii}(2), 'Callback', @extractInput)
    set(h{ii}(2), 'String', DefaultInput{ii});
    pos = get(h{ii}(2), 'Position');
    pos(3) = 150;
    set(h{ii}(2), 'Position', pos);
end

signalScaleFlag = strcmpi(db.Name, 'signal scaling');
g = addblock(db, 'custom', {'button', 'button'}, {'OK', 'Cancel'});
pos = get(g(1), 'Position');
pos(3) = 30;
set(g(1), 'Position', pos);
pos2 = get(g(2), 'Position');
pos2(1) = pos(1) + pos(3) + 10;
set(g(2), 'Position', pos2);

set(g(1), 'Callback', @okButton)
set(g(2), 'Callback', @cancelButton)

if signalScaleFlag
    h_auto = addblock(db, 'custom', {'button', 'radio'}, {'Auto', {'PS', 'GA'}});
    pos1 = get(h_auto(1), 'Position');
    pos1(3) = 50;
    set(h_auto(1), 'Position', pos1);
    set(h_auto(1), 'Callback', @autoButton)
    pos2 = get(h_auto(2), 'Position');
    pos2(1) = pos1(1) + pos1(3) + 10;
    pos2(3) = 40;
    pos2(2) = pos2(2)-5;
    set(h_auto(2), 'Position', pos2);
    pos3 = get(h_auto(3), 'Position');
    pos3(1) = pos2(1) + pos2(3) + 5;
    pos3(3) = 40;
    pos3(2) = pos3(2) - 5;
    set(h_auto(3), 'Position', pos3);
    set(h_auto(2), 'Value', 1);
    algorithmType = get(h_auto(2), 'string');
    set(h_auto(2:3), 'Callback', @autoRadio)
    validLicense = license('test', 'GADS_Toolbox');
end

lastInput = DefaultInput;

% dynamically extract input and update record

    function extractInput(varargin)
        record = get(fig, 'UserData');
        result = nan(size(prompt));
        for jj = 1:numel(h)
            inp = get(h{jj}(2), 'string');
            inpNum = sscanf(inp, '%g');
            if isempty(inpNum)
                set(h{jj}(2), 'string', lastInput{jj});
                return
            end
            result(jj) = inpNum;
            lastInput{jj} = inp;
        end
        if iscell(default)
            func=num2cell(result);
        else
            func=result;
        end
        record.(fieldName) = func;
        ReadEditRecordGUI(record);
    end

% close GUI on OK

    function okButton(src, varargin)
        delete(get(src, 'parent'));
    end

% revert to default and close GUI on Cancel

    function cancelButton(src, varargin)
        record = get(fig, 'UserData');
        record.(fieldName) = default;
        ReadEditRecordGUI(record);
        delete(get(src, 'parent'));
    end

% automated scaling

    function autoButton(src,varargin)
        if ~validLicense
            errordlg('Global Optimization Toolbox Required');
            return
        end
        record.(fieldName) = [1 1 1 1];
        record = VisarAnalysis(record, 'PreProcessing','QuadratureSignals');
        startDistance = double(sqrt(record.D{1}.^2 + record.D{2}.^2));
        upperBound = ones(1,4)./(0.8*min(startDistance));
        lowerBound = ones(1,4)./(1.2*max(startDistance));
        x0 = ones(1,4)./mean(startDistance);
        fun = @(in)optfun(in, record, fieldName);
        switch lower(algorithmType)
            case 'ps'
                opts = optimoptions('patternsearch', Algorithm='nups', Display='none', ...
                    PlotFcn='psplotbestf');
                x = patternsearch(fun, x0, [], [], [], [], lowerBound, upperBound, ...
                    [], opts);
            case 'ga'
                opts = optimoptions('ga', Display='none', ...
                    PlotFcn='gaplotbestf');
                x = ga(fun, 4, [], [], [], [], lowerBound, upperBound, [], opts);
        end
        record.(fieldName) = x;
        for jj = 1:length(x)
            set(h{jj}(2), 'String', sscanf(FixedG(x(jj),sigfigs),'%s'));
        end

        hax=findobj(fig,'Tag','ProcessedSignals');
        xlimUser = xlim(hax);
        ReadEditRecordGUI(record);
        axis(hax, 'tight');
        ReadEditRecordGUI(record);
        xlim(hax, xlimUser);

        close(findobj(0,'Name','Pattern Search'))
        close(findobj(0,'Name','Genetic Algorithm'))
    end

    function autoRadio(src,varargin)
        set(h_auto(2:3), 'Value', 0);
        algorithmType = get(src, 'String');
        set(src, 'Value', 1);
    end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function func=ExtractData(data,element)

if isnumeric(data)
    func=data(element);
end

if iscell(data)
    func=data{element};
end

end

function score = optfun(in, record, fieldName)
record.(fieldName) = in;
record = VisarAnalysis(record, 'PreProcessing', 'QuadratureSignals');
score = sum(abs(1 - sqrt(record.D{1}.^2 + record.D{2}.^2)))/numel(record.D{1});
end