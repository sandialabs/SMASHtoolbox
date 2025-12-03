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

cb = SMASH.MUI2.ComponentBox;
set(cb.Figure, 'Tag', 'DoubleInputDlg_dynamic');
setName(cb, title);
h = cell(1,length(prompt));
for ii = 1:length(prompt)
    h{ii} = addEdit(cb, 5);
    h{ii}(1).Text = prompt{ii};
    set(h{ii}(2), 'ValueChangedFcn', @extractInput)
    set(h{ii}(2), 'Value', DefaultInput{ii});
    newRow(cb);
end

g = addButton(cb, 5);
g.Text = 'OK';
set(g, 'ButtonPushedFcn', @okButton)
g = addButton(cb, 5);
g.Text = 'Cancel';
set(g, 'ButtonPushedFcn', @cancelButton)

if strcmpi(cb.Name, 'signal scaling')
    newRow(cb);
    h1 = addButton(cb, 3);
    h1.Text = 'Auto';
    set(h1, 'ButtonPushedFcn', @autoButton);
    h2 = addRadio(cb, 2, 2, 'h', 'off');
    h2(1).Text = 'PS';
    h2(2).Text = 'GA';
    algorithmType = h2(1).Text;
    set(get(h2(1), 'parent'), 'SelectionChangedFcn', @autoRadio)
    validLicense = license('test', 'GADS_Toolbox');
end

fit(cb);
locate(cb, 'West', fig);
show(cb);

lastInput = DefaultInput;

% dynamically extract input and update record

    function extractInput(varargin)
        record = get(fig, 'UserData');
        result = nan(size(prompt));
        for jj = 1:numel(h)
            inp = get(h{jj}(2), 'Value');
            inpNum = sscanf(inp, '%g');
            if isempty(inpNum)
                set(h{jj}(2), 'Value', lastInput{jj});
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

% close GUI on OK (changes already occured)

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
            set(h{jj}(2), 'Value', sscanf(FixedG(x(jj),sigfigs),'%s'));
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
        algorithmType = get(get(src, 'SelectedObject', 'Text'));
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