%  remove Remove font calibration
%
% This *static* method removes an existing font calibration.
%    calfont.remove(index);
% Optional "index"  Input "index" indicates fonts in the order they were
% calibrated. Given N fonts, "index" can be values from 1 to N, where 1
% indicates the first font, 2 the second font, and so forth.  Index values
% from -N+1 to 0 reference in the opposite manner, e.g.  0 indicates the
% last calibrated font and -1 the one before that.  Omitting the index:
%    calfont.choose();
% prompts the user to choose a font in the command window using a positive
% integer. fonts in the order they were calibrated. Given
% N fonts, "index" can be values from 1 to N, where 1 indicates the first
% font, 2 the second font, and so forth.  Index values from -N+1 to 0
% reference in the opposite manner, e.g.  0 indicates the last calibrated
% font and -1 the one before that.  Omitting the index:
%    calfont.choose();
% prompts the user to choose a font in the command window using a positive
% integer.
%
% See also calfont, add, choose, query
%
function remove(index)

data=calfont.get();
assert(isfinite(data.Choice),'ERROR: no calibrated fonts');
N=numel(data.Calibration);

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

data.Calibration=data.Calibration([1:index-1 index+1:end]);
if N > 1
    data.Choice=data.Choice-1;
else
    data.Choice=nan();
end
setappdata(groot(),'calfont',data);

end