% export Generate standalone commands
%
% This method generates MATLAB commands for creating a component box
% separately from this class.  These commands can be written to an m-file:
%    export(object,name); % direct file selection
%    export(object,'');   % interactive file selection
% or copied to the system clipboard.
%    export(object);
% Exported commands replicate the current box with explicit function calls
% for distribution, emphasizing visual layout/format and stored data.   
% Interactive functionality (callbacks) are *not* preserved.
%
% See also ComponentBox, clipboard
%
function export(object,file)

% manage input
create=true();
if nargin() < 2
    create=false();
elseif isempty(file)
    [file,location]=uiputfile({'*.m' 'MATLAB files'},'Export file',...
        'ExportedComponentBox.m');
    if isnumeric(file)
        return
    end
    file=fullfile(location,file);
else
    assert(ischar(file) || isStringScalar(file),...
        'ERROR: invalid file name');
    [location,name,ext]=fileparts(file);
    if ~strcmpi(ext,'.m')
        file=fullfile(location,[name '.m']);
        fprintf('File extension changed to .m\n');
    end
    try
        fid=fopen(file,'w');
    catch
        error('ERROR: invalid file name');
    end
    fclose(fid);
end

fprintf('Exporting component box...');

% characterize figure
fit(object);
pos=getpixelposition(object.Figure);
pos(1:2)=1;

command{1}=sprintf('%% Component box exported %s \n',datetime('now'));
command{end+1}='fig=uifigure(''Units'',''pixels'',...';
command{end+1}=sprintf('\t''Position'',[%g %g %g %g],...',pos);
name={'Name' 'Resize' 'Scrollable'};
for n=1:numel(name)
    buffer=convertValue(object.Figure.(name{n}));
    command{end+1}=sprintf('\t''%s'',%s,...',name{n},buffer); %#ok<AGROW>
end
command{end}=sprintf('%s);\n',command{end}(1:end-4));

% characterize components
junk=uifigure('Visible','off');
CU=onCleanup(@() delete(junk));
skip={'FontName' 'FontSize' 'Position' 'Fcn' 'Parent' ...
    'Buttons','Object' 'Children' 'DisplayData'};
    function changed=compare2default(target)
        parent=junk;
        if contains(class(target),{'RadioButton' 'ToggleButton'})
            parent=uibuttongroup(junk);
        end
        dummy=feval(class(target),'Parent',parent);
        name=properties(dummy);
        keep=false(size(name));
        for nn=1:numel(name)
            if contains(name{nn},skip)
                continue
            elseif isequal(target.(name{nn}),dummy.(name{nn}))
                continue
            end
            keep(nn)=true();
        end
        changed=name(keep);
    end

counter=1;
for k=1:numel(object.Component)
    source=object.Component(k);
    ref=sprintf('h%d',counter);
    counter=counter+1;
    command{end+1}=sprintf('%s=%s(''Parent'',fig,...',...
        ref,class(source)); %#ok<AGROW>
    command{end+1}=sprintf('\t''Position'',%s,...',...
        convertValue(source.Position)); %#ok<AGROW>        
    if isprop(source,'FontName')
        command{end+1}=sprintf('\t''FontName'',''%s'',''FontSize'',%d,...',...
            source.FontName,source.FontSize); %#ok<AGROW>
    end
    name=compare2default(source);
    for n=1:numel(name)
        buffer=convertValue(source.(name{n}));
        command{end+1}=sprintf('\t''%s'',%s,...',name{n},buffer); %#ok<AGROW>
    end
    command{end}=sprintf('%s);\n',command{end}(1:end-4));
    if contains(class(source),'ButtonGroup')
        child=source.Children;
        for m=1:numel(child)
            sub=sprintf('h%d',counter);
            counter=counter+1;
            command{end+1}=sprintf('%s=%s(''Parent'',%s,...',...
                sub,class(child(m)),ref); %#ok<AGROW>
            command{end+1}=sprintf('\t''Position'',%s,...',...
                convertValue(child(m).Position)); %#ok<AGROW>
            command{end+1}=sprintf('\t''FontName'',''%s'',''FontSize'',%d,...',...
                child(m).FontName,child(m).FontSize); %#ok<AGROW>
            name=compare2default(child(m));
            for n=1:numel(name)
                buffer=convertValue(child(n).(name{n}));
                command{end+1}=sprintf('\t''%s'',%s,...',name{n},buffer); %#ok<AGROW>
            end
            command{end}=sprintf('%s);\n',command{end}(1:end-4));        
        end
    end
end

command{end+1}=sprintf('movegui(fig,''center'');\n');

%
fprintf('done\n');
if create()
    fid=fopen(file,'w');
    fprintf(fid,'%s\n',command{:});
    fclose(fid);
    edit(file);
else
    command=sprintf('%s\n',command{:});
    clipboard('copy',command);
    fprintf('Commands copied to clipboard\n');
end

end

function out=convertValue(in)

if isnumeric(in) || islogical(in)
    out=strtrim(sprintf('%g ',in));
    if ~isscalar(in)
        out=sprintf('[%s]',out);
    end
elseif isdatetime(in)
    out=sprintf('datetime(''%s'')',char(in));
elseif ischar(in) || isStringScalar(in) || ismethod(in,'char')
    out=sprintf('''%s''',char(in));
elseif iscellstr(in) || isstring(in)
    out='{';
    for n=1:numel(in)
        out=sprintf('%s ''%s''',out,in{n});
    end
    out=sprintf('%s}',strtrim(out));
elseif iscell(in)
    out='{';
    [rows,cols]=size(in);
    for m=1:rows        
        for n=1:cols
            new=convertValue(in{m,n});
            if n < cols
                out=sprintf('%s%s ',out,new);
            else
                out=sprintf('%s%s; ',out,new);
            end
        end
    end
    out=sprintf('%s}',strtrim(out));
else
    error('Not prepared for this!');
end

end