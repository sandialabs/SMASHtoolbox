% RESIZE resize an Image object
%
% This method resizes the Data field in an Image object and updates Grid1 
% and Grid2 via linear interpolation, maintaining the grid boundaries and 
% any non-uniformities
%
% Resize an object and specify the new lengths of Grid1 and Grid2
%     >> object=resize(object, Grid1Length, Grid2Length)
%
% Resize an object and additionally specify an interpolation method
% available to MATLAB's built-in imresize
%     >> object=resize(object, Grid1Length, Grid2Length, method)
%
% Resize an object directly with the imresize function inputs. The Image 
% object replaces the input image A. Note that numrows corresponds to Grid2 
% and numcolumns corresponds to Grid1.
%     >> object=resize(object, varargin);
%       -> Examples: object=resize(object, scale);
%                    object=resize(object, scale, 'nearest');
%                    object=resize(object, [numrows numcolumns])
% 
% See also Image
%

%
% created August, 2025 by Nathan Brown (Sandia National Laboratories)
%
function obj=resize(obj,varargin)

% implement imresize according to user input

if nargin > 2 && isscalar(varargin{1}) && isnumeric(varargin{2}) % specified Grid1 and Grid2 sizes
    numrows = varargin{2}; % Grid2
    numcolumns = varargin{1}; % Grid1
    if nargin == 3 % default interpolation
        obj.Data = imresize(obj.Data, [numrows numcolumns]);
    else % specified interpolation method
        obj.Data = imresize(obj.Data, [numrows numcolumns], varargin{3});
    end
else % direct input into imresize
    obj.Data = imresize(obj.Data, varargin{:});
end

% update grids (accounting for possible non-uniformities)

oldInd = 1:numel(obj.Grid1);
newInd = linspace(1, oldInd(end), size(obj.Data, 2));
obj.Grid1 = interp1(oldInd, obj.Grid1, newInd);

oldInd = 1:numel(obj.Grid2);
newInd = linspace(1, oldInd(end), size(obj.Data, 1));
obj.Grid2 = interp1(oldInd, obj.Grid2, newInd);

end