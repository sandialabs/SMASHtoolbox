% get Read existing font calibrations
%
% This *static* method reads existing font calibrations.
%    report=calfont.get();
% Output "report" is a structure with four fields, two of which
% (MonitorPositions and ScreenSize) indicate the display settings where the
% calibrations were performed.  The Choice field stores the index of the
% chosen font.  The Calibration field contains a structure array with one
% element per calibrated font.
%
% See also calfont
%
function data=get()

monpos=get(groot(),'MonitorPositions');
ss=get(groot(),'ScreenSize');
default=struct(...
    'MonitorPositions',monpos,'ScreenSize',ss,...
    'Choice',nan(),'Calibration',[]);

data=getappdata(groot(),'calfont');
if isempty(data) || ...
        ~isequal(monpos,data.MonitorPositions) || ...
        ~isequal(ss,data.ScreenSize)
    data=default;
    setappdata(groot(),'calfont',data);
end

end