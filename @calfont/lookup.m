% lookup Access font calibration
%
% This *static* method accesses an existing font calibration.  
%   report=calfont.lookup(index);
% Optional input "index" references fonts in the order they were
% calibrated. Given N fonts, "index" can be values from 1 to N, where 1
% indicates the first font, 2 the second, and so forth.  Index values from
% -N+1 to 0 reference in the opposite manner, e.g.  0 indicates the last
% calibrated font and -1 the one before that.  Omitting this input:
%    report=calfont.lookup();
% returns the chosen font.
%
% Existing calibrations can also be looked up by name and size.
%    report=calfont.lookup(name,points);
% An error is generated if no matching calibration is found.
%
% See also calfont, add, choose, query, show
%
function [cal,index,chosen]=lookup(varargin)

data=calfont.get();
N=numel(data.Calibration);

Narg=nargin();
if Narg < 1
    index=data.Choice;
    if isnan(index)
        fprintf('No chosen font, loading default...');
        calfont.add('');
        data=calfont.get();
        index=1;
        fprintf('done\n');
    end
elseif Narg == 1
    index=varargin{1};
    assert(isnumeric(index) && isscalar(index),...
        'ERROR: invalid font index');
    assert(N > 0,'ERROR: no calibrated fonts');
    valid=(-N+1:N);
    assert(any(index == valid),...
        'ERROR: index must be an integer from %+d to %+d',N-1,N)
    if index < 1
        index=index+N;
    end
elseif Narg == 2
    [name,pixels]=calfont.check(varargin{:});
    match=false();
    for n=1:N
        if strcmpi(data.Calibration(n).Name,name) && ...
                isequal(data.Calibration(n).Size,pixels)
            match=true();
            break
        end
    end
    assert(match,'ERROR: request does not any calibrated font');
    cal=data.Calibration(n);
    index=n;
    chosen=(n == data.Choice);
    return
else
    error('ERROR: invalid lookup request');
end

cal=data.Calibration(index);
if index == data.Choice
    chosen=true();
else
    chosen=false();
end

end