% add Add a new region of interest
%
% This method adds a new region of interest at the end of an existing array.
%    object=add(object); % use default mode
%    object=add(object,mode); % specify ROI mode
%    object=add(object,mode,name); % specify custom name
%

%
% created September 22, 2017 by Daniel Dolan (Sandia National Laboratories)
%
function object=add(object,mode,varargin)

% manage input
if (nargin < 2)
    mode='';
end

% call constructor
name=class(object);
new=feval(name,mode);
if nargin > 2
    new.Name = varargin{1};
end
object(end+1)=new;


end