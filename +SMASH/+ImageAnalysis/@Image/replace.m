% REPLACE Replace data values in an object
%
% This method replaces a rectangular region in an image with a specified
% value.  The replacement value *must* be specified; the replacement region
% can be specified or selected interactively.
%
% To replace values in a specific region:
%     >> object=replace(object,value,[xA xB],[yA yB]);
% where xA, xB, yA, and yB are bounding grid values.  When no bounding
% region is specified:
%     >> object=replace(object,value);
% the user is prompted to select the region.
% 
% See also Image
%

%
% created November 19, 2013 by Daniel Dolan (Sandia National Laboratories)
% revised March 13, 2015 by Daniel Dolan
%   -added interactive selection
%   -created documentation
% revised November, 2025 by Nathan Brown
function object=replace(object,value,varargin)
%function object=replace(object,value,array1,array2)

% manage input
Narg=numel(varargin);
if nargin==2 % manual select mode
    h=view(object,'show');
    title(h.axes,'Select replace region');    
    maskPoints = SMASH.ROI.selectROI({'Points', 'Closed'}, h.axes);
    close(h.figure);
    xv=maskPoints.Data(:,1);
    yv=maskPoints.Data(:,2);
    xq=repmat(object.Grid1,length(object.Grid2),1);
    yq=repmat(object.Grid2,1,length(object.Grid1));
    ind=inpolygon(xq,yq,xv,yv);
    object.Data(ind) = value;
    return
elseif Narg==1
    index=varargin{1};
    if islogical(index)
        assert(all(size(index)==size(object.Data)), ...
            'ERROR: invalid logical index for this object');
    else
        assert(isnumeric(index) & max(index) <= numel(object.Data) & ...
            min(index) > 0 & min(size(index)) == 1, ...
            'ERROR: invalid numeric index for this object')
    end
    object.Data(index)=value;
    return    
elseif Narg==2
    array1=varargin{1};
    array2=varargin{2};
else
    error('ERROR: invalid number of inputs');
end

% interpret array1 input
if islogical(array1) && (numel(array1)==numel(object.Grid1))    
    % valid request 
elseif strcmpi(array1,'all')
    array1=true(size(object.Grid1));
elseif isnumeric(array1) && (numel(array1)==2)
    array1=sort(array1);
    array1=(object.Grid1>=array1(1)) & (object.Grid1<=array1(2));
else
    error('ERROR: invalid replacement array');    
end

% interpret array2 input
if islogical(array2) && (numel(array2)==numel(object.Grid2))    
    % valid request 
elseif strcmp(array2,'all')
    array2=true(size(object.Grid2));
elseif isnumeric(array2) && (numel(array2)==2)
    array2=sort(array2);
    array2=(object.Grid2>=array2(1)) & (object.Grid2<=array2(2));
else
    error('ERROR: invalid replacement array');    
end

object.Data(array2,array1)=value;

%object=updateHistory(object);

end