% query List calibrated fonts
%
% This *static* method lists all calibrated fonts.  This information can be
% printed in the command window:
%    calfont.query();
% or returned as a cell array of character arrays (cellstr).
%    info=calfont.query();
%
% See also calfont, add, lookup, show
%
function varargout=query()

% look for previous calibrations
data=calfont.get();
if isempty(data)
    previous=[];
else
    previous=data.Calibration;
end
N=numel(previous);
list=cell(1,N);
for n=1:N
    list{n}=sprintf(' %3d:  %s %d pixel',n,previous(n).Name,previous(n).Size);  
     if n == data.Choice
         list{n}=[list{n} ' (current choice)'];
    end
end

% manage input
if nargout() > 0
    varargout{1}=list;
    varargout{2}=data.Choice;
elseif N == 0
    fprintf('No calibrated fonts\n');
else
    fprintf('Calibrated fonts:\n');
    fprintf('%s\n',list{:});
end

end