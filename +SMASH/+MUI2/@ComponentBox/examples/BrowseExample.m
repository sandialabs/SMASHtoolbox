% BrowseExample Component box example for browsing local files
% 
function select=BrowseExample(start,pattern)

% manage input
Narg=nargin();
if (Narg < 1) || isempty(start)
    start=pwd();
else
    assert(ispath(start),'ERROR: invalid start folder');
end

if (Narg < 1) || isempty(pattern)
    pattern='*';
else
    assert(ischar(pattern) || isStringScalar(pattern),...
        'ERROR: invalid filter');
end

% import namespace

% create box
select=[];
cb=ComponentBox();
setName(cb,'Browser example');
setFont(cb,'',18);

Location=addEdit(cb,40);
Location(1).Text='Location:';
Location(1).FontWeight='bold';
Location(2).Value=start;
Location(2).ValueChangedFcn=@updateLocation;
newRow(cb);

Filter=addEdit(cb,20);
Filter(1).Text='Filter pattern:';
Filter(1).FontWeight='bold';
Filter(2).Value=pattern;
Filter(2).ValueChangedFcn=@updateFilter;
Hidden=addCheckbox(cb,18);
Hidden.Text='Show hidden files';
Hidden.ValueChangedFcn=@updateHidden;
ShowHidden=false;
newRow(cb);

Content=addListbox(cb,20,10);
Content(1).Text='Content:';
Content(1).FontWeight='bold';
Content(2).DoubleClickedFcn=@chooseFolder;
newRow(cb);

Done=addButton(cb,10);
Done.Text='Done';
Done.ButtonPushedFcn=@pressDone;
Cancel=addButton(cb,10);
Cancel.Text='Cancel';
Cancel.ButtonPushedFcn=@pressCancel;

updateContent();
fit(cb);
locate(cb);
show(cb);
uiwait(cb.Figure);

% helper functions
    function updateLocation(varargin)
        new=Location(2).Value;
        try %#ok<TRYNC>
            cd(new);                               
        end
        new=pwd();
        start=new;
        Location(2).Value=new;        
        updateContent()
    end
    function updateFilter(varargin)
        pattern=Filter(2).Value;
        updateContent();
    end
    function updateHidden(varargin)
        ShowHidden=logical(Hidden.Value);
        updateContent();
    end
    function chooseFolder(varargin)
        target=Content(2).Value;
        target=fullfile(start,target);
        if isfolder(target)
            cd(target);
            start=pwd();
            Location(2).Value=start;
            updateContent();
        end
    end
    function updateContent(varargin)
        target=fullfile(start,pattern);
        data=dir(target);
        list=cell(size(data));
        keep=true(size(data));
        for nn=1:numel(data)
            if strcmp(data(nn).name,'..')
                list{nn}='..';
            elseif strcmp(data(nn).name,'.')
                keep(nn)=false;
            elseif (data(nn).name(1) == '.') && ~ShowHidden
                keep(nn)=false;
            elseif data(nn).isdir
                list{nn}=[data(nn).name filesep];
            else
                list{nn}=data(nn).name;
            end            
        end
        Content(2).Value={};
        Content(2).Items=list(keep);
    end
    function pressDone(varargin)
        select=fullfile(start,Content(2).Value);
        delete(cb);
    end
    function pressCancel(varargin)
        delete(cb);
    end

end