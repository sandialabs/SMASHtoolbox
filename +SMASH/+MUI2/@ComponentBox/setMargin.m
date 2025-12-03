% setMargin Set box margins
%
% This method sets the margins around components.
%    setMargin(object,value,units);
% Optional input "value" indicates the margin size, with a default value of
% 10.  Scalar values are shared for horizontal and vertical margins, or
% these can be individually specified by a two-element array.
%    setMargin(object,value,[hmargin vmargin]);
%  Margins must be non-negative numbers.
%
% Optional input "units" controls how margins are interpreted.  The default
% value 'pixels' uses specified values directly.  Specifying 'characters'
% allows margins to be defined in terms of the letter "W" for the current
% font settings.  Note that this character is almost never symmetric, so
% scalar/repeated values yield different horizontal and vertical margins.
%
% See also ComponentSizing, setFont, setMargin
%
function setMargin(object,value,units)

% manage input
Narg=nargin();
if (Narg < 2) || isempty(value)
    value=10;
else
    assert(isnumeric(value) && all(value >= 0),'ERROR: invalid gap');    
end
if isscalar(value)
    value=repmat(value,[1 2]);
else
    value=value(1:2);
end

if (Narg < 3) || isempty(units) || strcmpi(units,'pixels')
    units='pixels';
elseif strcmpi(units,'characters')
    units='characters';
else
    error('ERROR: units must be ''pixels'' or ''characters''');
end

% manage object arrays
if ~isscalar(object)
    for k=1:numel(object)
        setMargin(object(k),value,units);
    end
    return
end

% convert characters to pixels
if strcmp(units,'characters')
    value(1)=object.Calibration.textWidthFcn(value(1));
    value(2)=object.Calibration.textHeightFcn(value(2));
end

% store results
object.Margin.Horizontal=value(1);
object.Margin.Vertical=value(2);
refresh(object);

end