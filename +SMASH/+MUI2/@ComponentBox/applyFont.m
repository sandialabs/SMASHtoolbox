% applyFont Apply font settings to specified component(s)
% 
% This method applies the current font settings to one or more specified
% components.  This can be done to a specific target:
%    applyFont(object,target);
% or several distinct components at once.
%    applyFont(object,target1,target2,...);
% Any of the above inputs can be a graphic handle array or a cell array of
% graphic handles.  Invalid targets are automatically skipped without
% generating an error.
%
% See also ComponentBox, setFont, calfont
%
function applyFont(object,varargin)

M=numel(varargin);
for m=1:M
    group=varargin{m};
    for n=1:numel(group)
        if iscell(group)
            target=group{n};
        else
            target=group(n);
        end
        try %#ok<TRYNC>
            set(target,...
                'FontName',object.Font.Name,...
                'FontSize',object.Font.Size)
        end
    end
end

end