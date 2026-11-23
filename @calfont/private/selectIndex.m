function index=selectIndex(N)

valid=1:N;

commandwindow();
while true()
    index=[];
    calfont.query();
    fprintf('Choose font by index or type "q" to quit\n');
    temp=input('Choice: ','s');
    if strcmpi(strtrim(temp),'q')       
        return
    end
    index=sscanf(temp,'%d',1);
    if isempty(index) || ~any(index == valid)
        continue
    end
    break
end

end