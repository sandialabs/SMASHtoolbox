% setGap Set component gaps
%
% This method sets the gap size between components.
%    setGap(object,value,units);
% Optional input "value" indicates the gap size, with a default value of
% 10.  Scalar values are shared for horizontal and vertical gaps, or these
% can be individually specified by a two-element array.
%    setGap(object,[hgap vgap],units);
% Gap sizes must be non-negative numbers.
%
% Optional input "units" controls how gap sizes are interpreted.  The
% default value 'pixels' uses specified values directly.  Specifying
% 'characters' allows gaps to be defined in terms of the letter "W" for the
% current font settings.  Note that this character is almost never
% symmetric, so scalar/repeated values yield different horizontal and
% vertical gaps.
%
% See also ComponentSizing, setFont, setMargin
%
function setGap(object,value,units)

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
        setGap(object(k),value,units);
    end
    return
end

% convert characters to pixels
if strcmp(units,'characters')
    value(1)=object.Calibration.textWidthFcn(value(1));
    value(2)=object.Calibration.textHeightFcn(value(2));
end

% store results
object.Gap.Horizontal=value(1);
object.Gap.Vertical=value(2);

end