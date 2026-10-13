% popLabel Moved queued label(s) into component box
%
% This methods moves labels from the queue into a component block.
%    h=popLabel(object,type,...);
% Optional input "type" indicates the kind of block being added to the box;
% the default type is 'button'.  The requested type must match a block add*
% method: 'button' invokes the addButton, 'checkbox' invokes addCheckbox,
% and so forth.  Unlike direct calls to these methods, popping labels from
% the queue automatically sizes components based on text content and the
% current font size.  Output "h" is an array of graphic components added to
% the box.
%
% Simple block types (button, checkbox, hyperlink, radio, and toggle)
% generate one component per text label.
%    h=popLabel(object,type,number,style);
% Optional input "number" indicates the number of vertically-stacked
% components created, each one pulling its own label from the queue; the
% default value is 1.  Optional input "label" pertains to 'button' blocks
% only, indicating whether the component is a push or state button.
%
% Composite blocks ('colorpicker', 'datepicker', 'dropdown', 'edit',
% 'listbox', 'slider', 'spinner', 'textarea', and 'tree') generate two
% components per label.
%    h=popLabel(object,type,width2); % color/date pickers, dropdown, and spinner blocks
%    h=popLabel(object,type,width2,rows); % listbox and text area blocks
%    h=popLabel(object,type,width2,style); % edit and slider blocks
%    h=popLabel(object,type,width2,rows,style); % tree blocks
% Optional input "width2" allows the second component to have a different
% width than the label; the second component is assigned the same width as
% the label if this input is empty or omitted.  All other inputs are passed
% to the add* method.
%    -A style argument can be passed to edit, slider, and tree blocks.
%    -A rows argument can be passed to listbox, text area, and tree blocks.
% Refer to the corresponding add* method for more details.
%
% Tree blocks pull every label from the queue as columns, making each the
% same width.
%    h=popLabel(object,'table',rows);
% Optional input "rows" controls the vertical height, with a default value
% of 4.
%
% Message blocks pull one or more labels from the queue as rows of text.
%    h=popLabel(object,'message',rows);
% Optional input "rows" indicate how many labels are to be pulled.  If this
% input is omitted or empty.
%
% Image blocks use the text width stored in  the queue but do not pull
% remove label off.
%    h=popLabel(object,'image');
% 
% Pluralizing the block type repeatedly pops labels off the queue until
% none remain.  Typically this is done to quickly add simple components to
% the same row, e.g.:
%    h=popLabel(object,'buttons');
%    h=popLabel(object,'checkboxes');
% Vertical stacking can be combined with the horizontal raster.
%    h=popLabel(object,'radio',rows)
% A warning is generated when the number of queued labels is not a multiple
% of "rows", but all components up to the last column are generated.
%
% See also MyComponent, flushLabel, pushLabel, setFont
%
function h=popLabel(object,type,varargin)

data=object.LabelQueue;
assert(~isempty(data.Content),'ERROR: label queue is empty');

% manage input
Narg=nargin();
if (Narg < 2) || isempty(type)
    type='button';
else
    assert(ischar(type) || isStringScalar(type),...
        'ERROR: invalid component request');
end

% manage plural case
if lower(type(end)) == 's'
    if strcmpi(type,'checkboxes')
        type=type(1:end-2);
    else
        type=type(1:end-1);
    end
    h=[];
    while ~isempty(object.LabelQueue.Content)
        try
            new=popLabel(object,type,varargin{:});
        catch
            warning('popLabel:ranout',...
                'Ran out of labels on last component');
            break
        end
        h=[h new]; %#ok<AGROW>
    end    
    return
end

% invoke add method
width=data.Width;
label{1}=data.Content{1};

name=type;
name(1)=upper(name(1));
name=['add' name];
switch lower(type)
    case {'button' 'checkbox' 'hyperlink' 'radio' 'toggle'} % simple
        number=numel(object.LabelQueue);
        if numel(varargin) > 0
            number=varargin{1};
        end       
        try
            label=data.Content(1:number);
            if strcmpi(type, 'radio')
                label = label(end:-1:1); % accounts for undoing the reversed handle in addRadio
            end
        catch
            error('ERROR: invalid number of buttons');
        end
        varargin{1}=number;
    case {'colorpicker' 'datepicker' 'dropdown' 'edit' ...
            'listbox' 'slider' 'spinner' 'textarea' 'tree'} % composite      
        width2=[];
        if numel(varargin) > 0
            width2=varargin{1};
            varargin=varargin(2:end);
        end
        if ~isempty(width2)
            width=[width width2];
        end    
    case 'table'
        label=data.Content;
        width=repmat(width,size(label));
    case 'message'
        if (numel(varargin) < 1) || isempty(varargin{1})
            rows=numel(object.LabelQueue.Content);
            varargin{1}=rows;
        else
            rows=varargin{1};
        end
        try
            label=data.Content(1:rows);
        catch
            error('ERROR: invalid number of text rows');
        end
    case 'image'
        % keep going
    otherwise
        error('ERROR: invalid component request');
end

try
    h=feval(name,object,width,varargin{:});
catch ME
    throwAsCaller(ME);
end

% place labels where they go and update queue
for n=1:numel(label)
    switch name
        case 'addMessage'
            set(h(1),'Text',label);
            break
        case 'addImage'
            label={};
            return
        otherwise
            set(h(n),'Text',label{n});
    end
end

start=numel(label)+1;
object.LabelQueue.Content=object.LabelQueue.Content(start:end);

end