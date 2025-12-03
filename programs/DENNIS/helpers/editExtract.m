function out = editExtract(h_edit)

h_edit = findobj(h_edit, 'Type', 'uieditfield');
out = nan(1, length(h_edit));
for ii = 1:length(h_edit)
    try
        out(ii) = eval(get(h_edit(ii), 'Value'));
    catch
    end
end

end