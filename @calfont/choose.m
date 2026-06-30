% choose Select preferred font
%
% This *static* method selects the chosen font, which becomes the default
% calibration for the lookup method.
%    calfont.choose(index);
% Optional input "index" references fonts in the order they were
% calibrated. Given N fonts, "index" can be values from 1 to N, where 1
% indicates the first font, 2 the second font, and so forth.  Index values
% from -N+1 to 0 reference in the opposite manner, e.g.  0 indicates the
% last calibrated font and -1 the one before that.  Omitting the index:
%    calfont.choose();
% prompts the user to choose a font in the command window using a positive
% integer.
%
% Calling this method with no index:
%    calfont.choose();
%    [index,name,pixels]=calfont.choose();
% prints the current index in the command window or returns the value as an
% output.  The value of "index" is NaN when no fonts have been calibrated,
% and both "name" and "pixels" are empty.
%  
% See also calfont, add, lookup, query, remove, show, set
%
function varargout=choose(index)

data=calfont.get();
assert(isfinite(data.Choice),'ERROR: no calibrated fonts');
N=numel(data.Calibration);

if (nargout() > 0)
    index=data.Choice;
    varargout{1}=index;
    if isnan(index)
        varargout{2}='';
        varargout{3}=[];
    else
        varargout{2}=data.Calibration(index).Name;
        varargout{3}=data.Calibration(index).Size;
    end
    return
end

%%
if (nargin() < 1) || isempty(index)
    index=selectIndex(N);
    if isempty(index)
        return
    end
end

try
    [~,index]=calfont.lookup(index);
catch ME
    throwAsCaller(ME);
end

data.Choice=index;
setappdata(groot(),'calfont',data);

end