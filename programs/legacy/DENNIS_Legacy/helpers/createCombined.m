function [new, fig, ax] = createCombined(src, cb, name)

% never attempt to create combined before checking for and creating cb

tag = cb.Name;
[parent, new, fig] = combine(cb, [], 'hide');
delete(cb);
ax = axes(parent(2), 'Units', 'normalized', 'OuterPosition', [0 0 1 1]);
set(ax.Title, 'Visible', 'off');
fig.Name = name;
setappdata(src, tag, fig);

end