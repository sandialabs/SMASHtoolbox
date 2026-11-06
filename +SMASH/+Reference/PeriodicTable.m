% PeriodicTable Access data from the periodic table
%
% This function provides element data from the periodic table.  
% Numeric input:
%   entry=PeriodicTable(number);
% looks up an element by atomic number.  Character input:
%   entry=PeriodicTable(symbol);
%   entry=PeriodicTable(name);
% looks up an element by symbol or name; the former is case sensitive but
% the latter is not.  The output "entry" is a structure with fields Symbol,
% Name, Mass, and so forth.
%
% Calling this function with no input:
%    PeriodicTable();
% displays an interactive periodic table.
%
% NOTE: text is automatically sized with the current calfont choice.  If
% not choice has been made, the default font is used 
%
% See also SLAM.Reference, calfont
%
function varargout=PeriodicTable(request)

% manage input
if (nargin == 0) || isempty(request)
   browse();
   return
end

% look up requested element
DataTable=lookup([]);
Nelements=numel(DataTable);

if isnumeric(request)
    valid=1:Nelements;
    assert(isscalar(request) && any(request == valid),...
        'ERROR: invalid atomic number');
else
    assert(ischar(request),'ERROR: invalid table request');
    match=false;
    for n=1:Nelements
        if strcmp(request,DataTable(n).Symbol)
            request=n;
            match=true;
            break
        end
    end
    if ~match
        for n=1:Nelements
            if strcmpi(request,DataTable(n).Name)
                request=n;
                match=true;
                break
            end
        end
        assert(match,'ERROR: invalid symbol/name');            
    end    
end

varargout{1}=lookup(request);

end

%%
function data=lookup(number)

persistent DataTable 
if isempty(DataTable)
    file=fileparts(mfilename('fullpath'));
    file=fullfile(file,'data','PeriodicTable.json');
    fid=fopen(file,'r');
    temp=fscanf(fid,'%c');
    fclose(fid);
    DataTable=jsondecode(temp);
end

% return data
if isempty(number)
    data=DataTable;
else
    data=DataTable(number);
end

end

%%
function browse(varargin)

DataTable=lookup([]);
block=cell(size(DataTable));
for k=1:numel(block)
    block{k}=DataTable(k).Block;
end
block=unique(block);
BlockColor=ones(numel(block),3);

try
    [~,name,pixels]=calfont.choose();
catch
    new=calfont.add('',40,'rows');
    name=new.Name;
    pixels=new.Size;
end

cb=SLAM.Developer.ComponentBox();
setName(cb,'Periodic table');
setFont(cb,name,pixels);

hAxes=addTextarea(cb,40,14); % sizing placeholder
newRow(cb);
hProperties=addTextarea(cb,40,6);
newRow(cb);
hReference=addHyperlink(cb,40);
fit(cb);
locate(cb,'center');

pos=getpixelposition(hAxes(2));
delete(hAxes);

set(hProperties(1),'FontWeight','bold');
set(hProperties(2),'ValueChangedFcn',@undoTyping);
    function undoTyping(src,varargin)
        set(src,'Value',get(src,'UserData'));
    end

current=cb.Font;
hAxes=axes('Parent',cb.Figure,'YDir','reverse','Toolbar',[]);
setpixelposition(hAxes,pos);
number=0;
pos=[-0.5 -0.5 1 1];
for m=1:9
    pos(1)=-0.5;
    pos(2)=pos(2)+1;
    for n=1:18    
        pos(1)=pos(1)+1;
        switch m
            case 1
                if ~any(n == [1 18])
                    continue
                end
            case 2 
                if ~any(n == [1 2 13:18])
                    continue
                end
            case 3
                if ~any(n == [1 2 13:18])
                    continue
                end
            case 4
                % do nothing
            case 5
                % do nothing
            case 6                
                if any(n == 3)
                    number=71;
                    continue
                end
            case 7
                if any(n == 3)
                    number=103;
                    continue
                end
            case 8
                if n == 1                    
                    pos(2)=pos(2)+0.5;
                end
                if n == 2
                    number=56;
                end                  
                if ~any(n == 3:17)
                    continue
                end
            case 9
                if n == 2
                    number=88;
                end
                if ~any(n == 3:17)
                    continue
                end
        end
        number=number+1;
        for jj=1:numel(block)
            if strcmp(DataTable(number).Block,block{jj})
                color=BlockColor(jj,:);
                break
            end
        end
        rectangle('Parent',hAxes,'Position',pos,'FaceColor',color,...
            'ButtonDownFcn',@selectElement,'UserData',DataTable(number),...
            'Tag',DataTable(number).Symbol);        
        switch lower(DataTable(number).StandardPhase)
            case 'solid'
                FontColor='k';
            case 'liquid'
                FontColor='b';
            case 'gas'
                FontColor='r';
        end        
        text('Parent',hAxes,'Position',pos(1:2)+pos(3:4)/2,...
            'String',DataTable(number).Symbol,...
            'FontName',current.Name,'FontSize',current.Size,...
            'Color',FontColor,'HorizontalAlignment','center',...
            'ButtonDownFcn',@selectElement,'UserData',DataTable(number))
        text('Parent',hAxes,'Position',[pos(1)+0.05*pos(3) pos(2)+0.05*pos(4)],...
            'String',sprintf('%d',number),...
            'FontName',current.Name,'FontSize',current.Size*0.40,...
            'HorizontalAlignment','left','VerticalAlignment','top',...
            'ButtonDownFcn',@selectElement,'UserData',DataTable(number))
    end
end
axis(hAxes,'tight');
axis(hAxes,'off');
hBlock=findobj(hAxes,'Type','rectangle'); hBlock=hBlock(end:-1:1);
    function selectElement(src,varargin)
        data=get(src,'UserData');
        number=data.Number;
        for kk=1:numel(hBlock)
            temp=get(hBlock(kk),'UserData');
            if temp.Number == number
                set(hBlock(kk),'FaceColor','y');
            else
                set(hBlock(kk),'FaceColor','w');
            end
        end        
        label=sprintf('Properties of %s (%s)',data.Symbol,data.Name);
        set(hProperties(1),'Text',label);
        label={};
        label{end+1}=sprintf('Atomic number: %g',data.Number);
        label{end+1}=sprintf('Atomic mass: %g',data.Mass);
        label{end+1}=sprintf('Series: %s',data.Block);
        if strcmpi(data.StandardPhase,'gas')
            units='g/L';
        else
            units='g/cc';
        end        
        label{end+1}=sprintf('Standard density: %g %s (%s)',...
            data.StandardDensity,units,lower(data.StandardPhase));
        label{end+1}=sprintf('Configuration: %s',data.Configuration);
        label{end+1}=sprintf('Melting point: %g K',data.Melt);
        label{end+1}=sprintf('Boiling point: %g K',data.Boil);
        set(hProperties(2),'Value',label,'UserData',label);
        set(hReference,'Text',data.Reference,'URL',data.Reference);
    end

selectElement(hBlock(1));

set(cb.Figure,'KeyPressFcn',@keyfunc)
    function keyfunc(~,keydata)
        current=findobj(cb.Figure,'FaceColor','y');
        data=get(current,'UserData');
        number=data.Number;
        group=data.Group;
        try
            switch keydata.Key
                case 'rightarrow'
                    new=lookup(number+1);
                case 'leftarrow'
                    new=lookup(number-1);
                case 'uparrow'
                    while true()
                        number=number-1;
                        new=lookup(number);
                        if new.Group == group
                            break
                        end
                    end
                case 'downarrow'
                    while true()
                        number=number+1;
                        new=lookup(number);
                        if new.Group == group
                            break
                        end
                    end
                otherwise
                    return
            end
        catch
            return
        end        
        next=findobj(cb.Figure,'Tag',new.Symbol);
        selectElement(next);
    end

show(cb);

end