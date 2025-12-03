% add Add font calibration
%
% This *static* method adds a font calibration.
%    calfont.add(name,pixels);
% Optional inputs "name" and "pixels" indicate the desired font and its
% name.  Empty arguments invoke defaults based on the standard uilabel
% font.
%    calfont.add('',pixels); % default font, specified size
%    calfont.add(name,''); % specified font, default size
%    calfont.add('',''); % default font/size
% Omitting inputs altogether:
%    calfont.add();
% launches interactive font selection with the most recent addition as the
% default choice.
%
% Font size can be also be specified in terms of vertical rows.
%    calfont.add(name,value,'rows');
% The number of pixels derived from "value" allows roughly that many text
% rows to be simultaneous visible on the current display.  The calculation
% is imperfect for several reasons: the number of pixels report to MATLAB
% may not be fully accessible for plots; the smallest vertical size is used
% in multiple display systems; and results are rounded to the nearest
% integer.  Calculated font sizes are inversely proportional to the
% requested number of rows.
%
% Adding a new font calibration does not make that the chosen
% font unless no other fonts have been already been calibrated.  The choose
% method can be automatically invoked by adding the argument '-choose'
% anywhere within the inputs.
%    calfont.add(name,value,'-choose');
%    calfont.add('-choose',name,value);
% The location of this argument does not matter, as shown above.
% Interactively added fonts are automatically made the chosen font.
%
% NOTE: calibration may take several seconds, so care should be
% exercised when this method is used inside a loop.  Existing calibrations
% of the same name/size are overwritten automatically.
%
% See also calfont, check, choose, lookup, query, remove, show, set
%
function varargout=add(varargin)

% manage input
choose=false();
keep=true(size(varargin));
for n=1:numel(varargin)
    if strcmpi(varargin{n},'-choose')
        keep(n)=false();
        choose=true();
    end
end
varargin=varargin(keep);
if isempty(varargin)
    choose=true();
end

try
    [name,pixels]=calfont.check(varargin{:});
catch ME
    throwAsCaller(ME);
end

start=tic();
fprintf('Calibrating %s %d pixel font...',name,pixels);

% prepare staging figure
fig=uifigure('Name','Staging figure',...
    'AutoResizeChildren','off','Visible','off');
CU=onCleanup(@() delete(fig));
delay=0.01;

dummy=repmat('W',[1 10]);
label={'W' dummy dummy dummy};
N=numel(label);
for n=1:N
    hg=uigridlayout(fig,'ColumnWidth',{0},'RowHeight',{0});
    switch n
        case {1 2}
            hl=uilabel(hg,'Text',label{n});
        case 3
            hl=uicheckbox(hg,'Text',label{n});
        case 4
            hl=uidropdown(hg,'Items',string(label{n}));
    end
    if n == 1
        component=repmat(hl,size(label));
    else
        component(n)=hl;
    end
end

[code,symbol]=calfont.charset();
N=numel(symbol);
for n=1:N
    hg=uigridlayout(fig,'ColumnWidth',{0},'RowHeight',{0});
    hl=uilabel(hg,'Text',symbol(n));
    if n == 1
        character=repmat(hl,[1 N]);
    else
        character(n)=hl;
    end
end

hl=[component character];
while true()
    pos=cell2mat(get(hl,'Position'));
    pos=pos(:,3:4);
    same=(pos(:) ~= 0);
    if any(same)
        pause(delay);
        continue
    end
    break
end

set(hl,'FontName',name,'FontSize',pixels);
hg=findobj(fig,'Type','uigridlayout');
set(hg,'ColumnWidth',{'fit'},'RowHeight',{'fit'});
while true()
    pos=cell2mat(get(hl,'Position'));
    pos=pos(:,3:4);
    same=(pos(:) == 0);
    if any(same)
        pause(delay);
        continue
    end
    break
end
new=struct('Name',name,'Size',pixels);

% component calibration
pos=cell2mat(get(component,'Position'));
param=polyfit([1 10],pos(1:2,3),1);
new.textWidthFcn=@(cols) polyval(param,cols);
new.textHeightFcn=@(rows) rows*pos(4,4);
new.boxSizeFcn=@(n) n*(pos(3,3)-pos(2,3));

% character calibration
pos=cell2mat(get(character,'Position'));
width=pos(:,3);
ref=interp1(code,width,87,'nearest'); % "W" character
width=width/ref;
new.CharacterData=[code(:) width(:)];
CharLookup=griddedInterpolant(code,width,'nearest');
new.WidthFcn=@(varargin) calculateWidth(CharLookup,varargin{:});

% store result
new.Completed=char(datetime('now'));
data=calfont.get();
cal=data.Calibration;
match=false();
for n=1:numel(cal)
    if strcmpi(cal(n).Name,name) && (cal(n).Size == pixels)
        match=true();
        cal(n)=new;
        break
    end
end

if ~match
    if isempty(cal)
        cal=new;
    else
        cal(end+1)=new;
    end
end
data.Calibration=cal;
if isnan(data.Choice)
    data.Choice=1;
end
setappdata(groot(),'calfont',data);

total=toc(start);
fprintf('done\n');

if choose
    calfont.choose(0);
end

% manage output
if nargout() > 0
    varargout{1}=new;
    varargout{2}=total;
end

end

%%
function [w,cols]=calculateWidth(Q,varargin)

Narg=numel(varargin);

assert(Narg >= 1,'ERROR: insufficient input');
in=varargin{1};

if (Narg < 2) || isempty(varargin{2})
    padding=0;
else
    padding=varargin{2};
    assert(isnumeric(padding) && isscalar(padding) && (padding >= 0),...
        'ERROR: invalid character padding');
end

if isstring(in) || iscellstr(in)
    w=0;
    cols=0;
    for nn=1:numel(in)
        arg=char(in{nn});
        w=max(w,calculateWidth(Q,arg,padding));
        cols=max(cols,numel(arg,padding));
    end
    return
elseif ischar(in)
    in=double(in);
end

assert(isnumeric(in),'ERROR: invalid text input');
w=sum(Q(in))+padding;
cols=numel(in);
end