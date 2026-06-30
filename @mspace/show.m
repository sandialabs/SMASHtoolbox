% show Reveal workspaces or workspace contents
%
% This method reveals the workspaces defined in the current MATLAB
% session.
%    mspace.show(); % display workspace names
%    name=mspace.show(); % returns a cell array of names
% The contents of a specific workspace can also be displayed.
%    mspace.show(name); % display workspace content
%    data=mspace.show(name); % returns a structure of workspace contents
%
% See also mspace
%
function varargout=show(name)

data=getSpace();
if nargin == 0
    out=cell(size(data));
    for n=1:numel(data)
        out{n}=data(n).Name;
    end
    if nargout == 0
        if isempty(out)
            fprintf('No spaces defined\n');
        else
            fprintf('Defined spaces:\n');
            fprintf('   %s\n',out{:});
        end
    else
        varargout{1}=out;
    end
elseif (nargin == 1) && ischar(name)
    found=false;
    for n=1:numel(data)
        if strcmp(data(n).Name,name)
            data=data(n);
            found=true;
            break
        end
    end
    assert(found,'ERROR: space "%s" does not exist',name);    
    if nargout == 0  
        if data.Locked
            fprintf('Locked MATLAB space "%s" using %s\n',...
                data.Name,showBytes(data.Bytes));
        else
            fprintf('Unlocked MATLAB space "%s" using %s\n',...
                data.Name,showBytes(data.Bytes));
        end
        fprintf('Created %s, modified %s\n',data.Created,data.Modified);
        fprintf('Description:\n');
        if isempty(data.Description)
            fprintf('   (none)\n');
        else
            fprintf('   %s\n',data.Description);
        end
        fprintf('Directory:\n   %s\n',data.Directory);
        fprintf('Variables:\n');
        if isempty(data.Variable)
            fprintf('   (none)\n');
        else
            varname=fieldnames(data.Variable);
            for n=1:numel(varname)
                temp=sprintf('%dx',size(data.Variable.(varname{n})));
                temp=temp(1:end-1);
                fprintf('   %s (%s %s)\n',...
                    varname{n},temp,class(data.Variable.(varname{n})));
            end
        end               
    else
        varargout{1}=data;
    end
else
    error('ERROR: invalid input');
end

end