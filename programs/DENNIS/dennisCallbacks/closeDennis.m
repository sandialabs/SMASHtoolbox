function closeDennis(src, event)

warning('off', 'all');

things2close = getappdata(src);
names = fieldnames(things2close);
for ii = length(names):-1:6 % closes all the dialogs
    delete(things2close.(names{ii}));
end

delete(src); % closes DENNIS

warning('on', 'all');

end