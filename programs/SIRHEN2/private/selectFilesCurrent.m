% This function selects multiple signal files.
%    list=selectFilesCurrent();
% The output "list" is a cell array of file import specifications: file
% name, file format, and record number.  These specifications can passed
% directly to the readFile function.
%
% See also SMASH.FileAccess.readFile
%

function specification=selectFilesCurrent(MainFigure)

if nargin() < 1
    MainFigure=[];
end

specification={};

% create dialog box
cb=SMASH.MUI2.ComponentBox();
setName(cb,'Select data files');

pushLabel(cb,'Signal data file(s)');
h=popLabel(cb,'message');
set(h,'Text','Signal data file(s)','FontWeight','bold');
pushLabel(cb,'Supported formats');
Formats=popLabel(cb,'button');
set(Formats,'ButtonPushedFcn',@showFormats);
    function showFormats(varargin)
        junk=SMASH.MUI2.ComponentBox();
        setName(junk,'Supported formats');
        message={};
        message{end+1}='Supported signal formats:';
        message{end+1}='   Agilent/Keysight binary files (*.h5 and *.bin)';
        message{end+1}='   LeCroy binary files (*.trc)';
        message{end+1}='   NTS binary files (*.dig)';
        message{end+1}='   Tektronix binary files (*.isf and *.wfm)';
        message{end+1}='   Text files (*.csv, *.dat, and *.txt)';
        message{end+1}='   Thrifty array files (*.taf)';
        pushLabel(junk,message);
        popLabel(junk,'message',numel(message));
        newRow(junk);
        pushLabel(junk,'Done');
        h=popLabel(junk,'button');
        set(h,'ButtonPushedFcn',@(~,~) delete(gcbf()));
        fit(junk);
        locate(junk,'center',cb.Figure);
        setWindowStyle(junk,'modal');
        show(junk);
    end
newRow(cb);

Directory=addTextarea(cb,20,2);
Directory(3)=addButton(cb,7);
set(Directory(1),'Text','Current folder:','FontWeight','bold');
set(Directory(2),'ValueChangedFcn',@changeDirectory,...
    'HorizontalAlignment','left','WordWrap','on');
 function changeDirectory(varargin)
        target=get(Directory(2),'Value');        
        if ~isfolder(target)
            target=get(Directory(2),'UserData');
        else
            temp=dir(target{1});
            target={temp(1).folder};
        end
        set(Directory(2),'Value',target,'UserData',target);                
        updateContents();
    end
set(Directory(3),'Text','Select','ButtonPushedFcn',@selectDirectory)
    function selectDirectory(varargin)
        start=get(Directory(2),'Value');        
        target=uigetdir(start{1},'Select directory');
        if ~isnumeric(target)
            set(Directory(2),'Value',target,'UserData',target);
            updateContents();
        end 
        show(cb)
    end
newRow(cb);

Contents=addListbox(cb,20,10);
set(Contents(1),'Text','Folder content:','FontWeight','bold');
set(Contents(2),'DoubleClickedFcn',@selectFile,...
    'Tooltip','Double-click to select file/directory');
    function selectFile(varargin)
        target=get(Directory(2),'Value');
        target=target{1};
        list=get(Contents(2),'Value');
        target=fullfile(target,list);
        if isfolder(target)
            temp=dir(target);
            target={temp.folder};   
            set(Directory(2),'Value',target,'UserData',target);
            updateContents();
            return
        end
        [~,short,ext]=fileparts(target);
        item=[short ext];                       
        switch lower(ext)
            case '.dig'
                entry={target 'dig' ''};
            case {'.h5' '.bin'}
                [item,entry]=selectRecord(target,'keysight');               
            case {'.wfm' '.isf'}
                [item,entry]=selectRecord(target,'tektronix');
            case '.trc'
                [item,entry]=selectRecord(target,'lecroy');
            case {'.txt' '.dat' '.csv'}
                [item,entry]=selectRecord(target,'column');
            case '.sda' % UNDER CONSTRUCTION
                return
            case '.taf' % UNDER CONSTRUCTION
                try
                    report=SMASH.ThriftyAnalysis.ArrayFile.probe(target);
                    assert((report.Dimensions == 2) && (report.Size(2) == 1));
                catch
                    error('ERROR: invalid TAF signal');                    
                end
                entry={target 'taf' ''};
            otherwise
                return
        end       
        if isempty(item)
            return
        end
        list=get(Selected(2),'Items');
        if isempty(list)
            list={item};
        else
            list{end+1}=item;
        end
        set(Selected(2),'Items',list);
        current=get(Selected(end),'UserData');        
        if isempty(current)
            current={entry};
        else
            current{end+1}=entry;
        end
        set(Selected(end),'UserData',current);                
    end
newRow(cb);

Selected=addListbox(cb,20,3);
Selected(3)=addButton(cb,8);
set(Selected(1),'Text','Selected files:','FontWeight','bold');
set(Selected(2),'Items',{});
set(Selected(3),'Text','Remove','ButtonPushedFcn',@remove);
    function remove(varargin)
        label=get(Selected(2),'Items');
        if isempty(label)
            return
        end
        index=get(Selected(2),'ValueIndex');           
        data=get(Selected(end),'UserData');        
        label=label([1:index-1 index+1:end]);
        data=data([1:index-1 index+1:end]);
        if index > 1
            index=index-1;
        elseif isempty(label)
            index=[];
        end        
        set(Selected(2),'Items',label,'UserData',data,'ValueIndex',index);        
    end
newRow(cb);

Finish(1)=addButton(cb,8);
set(Finish(1),'Text','Done','ButtonPushedFcn',@done);
    function done(varargin)
        specification=get(Selected(end),'UserData');   
        delete(cb);
    end

Finish(2)=addButton(cb,8);
set(Finish(2),'Text','Cancel','ButtonPushedFcn',@cancel);
    function cancel(varargin)
        delete(cb);
    end

% helper functions
DimText=uistyle('FontColor',repmat(0.5,[1 3]));
ValidExt={'.dig' '.h5' '.bin' '.wfm' '.isf' '.trc' ...
    '.txt' '.dat' '.csv' '.taf'};
    function updateContents()
        target=get(Directory(2),'Value');
        if iscellstr(target) || isstring(target)
            set(Directory(2),'Value',target(1));
            target=target{1};
        end
        file=dir(target);
        N=numel(file);
        list={};
        DimIndex=[];
        for n=1:N                  
            if file(n).name(1) == '.'
                if strcmp(file(n).name,'..')
                    % keep going                    
                else
                    continue
                end
            end
            list{end+1}=file(n).name; %#ok<AGROW>
            if file(n).isdir               
                list{end}=[list{end} filesep()];  
            else
                [~,~,ext]=fileparts(file(n).name);
                if ~any(strcmpi(ext,ValidExt))
                    DimIndex(end+1)=numel(list); %#ok<AGROW>
                end
            end
        end
        removeStyle(Contents(2));
        set(Contents(2),'ValueIndex',1,'Items',list);
        if ~isempty(DimIndex)
            addStyle(Contents(2),DimText,'item',DimIndex);
        end
    end

% finalize and display dialog box
set(Directory(2),'Value',pwd,'UserData',pwd);
updateContents();

fit(cb);
locate(cb,'center');
show(cb);
uiwait(cb.Figure);
if ishandle(MainFigure)
    figure(MainFigure);
end

end

function [item,entry]=selectRecord(target,format)

% {target format record}
[~,name,ext]=fileparts(target);
item=[name ext];
entry={target format ''};

try
    report=SMASH.FileAccess.probeFile(target,format);
catch ME
    throwAsCaller(ME);
end

switch format
    case 'column'
        switch report.NumberColumns
            case {0 1}
                error('ERROR: text files must have at least two columns');
            case 2
                % keep going
            otherwise
                %warning('SIRHEN2:ExtraColumns','Reading first two columns only');
        end
        entry{3}=[1 2];
        return
    case 'sda' %
        N=numel(report);
        channel=report;
        % case 'pff'
        %     object=SMASH.FileAccess.PFFfile(target);
        %     report=probe(object);
        %     N=numel(report);
        %     record=cell(1,N);
        %     label=cell(1,N);
        %     for n=1:N
        %         record{n}=n;
        %         label{n}=report(n).Title;
        %     end
    otherwise
        object=SMASH.FileAccess.DigitizerFile(target,format);
        report=probe(object);
        N=report.NumberSignals;
        if N > 1
            channel=report.Name;
        end
end

if N == 1
    return
end

cb=SMASH.MUI2.ComponentBox();

setName(cb,'Select channel');

h=addMessage(cb,20,2);
message{1}='Select channel from file:';
message{2}=sprintf('   %s',item);
set(h,'Text',message);
newRow(cb);

hList=addListbox(cb,20,4);
set(hList(1),'Text','Available channels:','FontWeight','bold');
set(hList(2),'Items',channel,'DoubleClickedFcn',@done);
newRow(cb);

choice=[];
index=[];
hButton(1)=addButton(cb,10);
set(hButton(1),'Text','Done','ButtonPushedFcn',@done);
    function done(varargin)
        choice=get(hList(2),'Value');
        index=get(hList(2),'ValueIndex');
        delete(cb);
    end

hButton(2)=addButton(cb,10);
set(hButton(2),'Text','Cancel','ButtonPushedFcn',@cancel);
set(cb.Figure,'CloseRequestFcn',@cancel);
    function cancel(varargin)
        delete(cb);
    end

fit(cb);
locate(cb,'center');
show(cb);

uiwait(cb.Figure);
if isempty(choice)
    item='';
    return
end

switch format
    case 'keysight'
        entry{3}=index;
        item=sprintf('%s, channel %d',item,index);
    otherwise
        entry{3}=choice;
        item=sprintf('%s, %s',item,choice);
end

end