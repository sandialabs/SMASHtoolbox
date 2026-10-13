% sysinfo Read system information
%
% This *static* method reads information about the local system.
%    report=handy.sysinfo();
% The output "report" is a structure with fields describing the system
% processor, memory, and operating system.
%
% See also handy
%
function info=sysinfo()

info=cpuinfoSource();

end

%%%%%%%%%%%%%%%%%%
% FEX submission %
%%%%%%%%%%%%%%%%%%

function info = cpuinfoSource()
%CPUINFO  read CPU configuration
%
%   info = CPUINFO() returns a structure containing various bits of
%   information about the CPU and operating system as provided by /proc/cpu
%   (Unix), sysctl (Mac) or WMIC (Windows). This information includes:
%     * CPU name
%     * CPU clock speed
%     * CPU Cache size (L2)
%     * Number of physical CPU cores
%     * Operating system name & version
%
%   See also: COMPUTER, ISUNIX, ISMAC

%   Author: Ben Tordoff
%   Copyright 2011-2023 The MathWorks, Inc.

if isunix
    if ismac
        info = cpuInfoMac();
    else
        info = cpuInfoUnix();
    end
else
    info = cpuInfoWindows();
end
end

%-------------------------------------------------------------------------%
function info = cpuInfoWindows()
sysInfo = callWMI( 'Processor', {'Name','MaxClockSpeed','L2CacheSize','NumberOfCores'} );
osInfo = callWMI( 'OperatingSystem', {'Caption'} );
computerInfo = callWMI( 'ComputerSystem', {'Name','TotalPhysicalMemory'} );

info = struct( ...
    'CPUName', strtrim(string(sysInfo.Name)), ...
    'Clock', [num2str(sysInfo.MaxClockSpeed),' MHz'], ...
    'Cache', double(sysInfo.L2CacheSize) * 1024, ... % Convert from kB
    'TotalMemory', double(computerInfo.TotalPhysicalMemory), ...
    'NumCPUs', sysInfo.NumCPUs, ...
    'TotalCores', double(sysInfo.NumberOfCores), ...
    'OSType', 'Windows', ...
    'OSVersion', char(osInfo.Caption), ...
    'Hostname', char(computerInfo.Name) );
end

%-------------------------------------------------------------------------%
function value = callWMI( alias, field )
% Call the WMI (Windows Management Interface) using MATLAB's .Net
% integration.
narginchk(2,2);

NET.addAssembly('System.Management');
objects = System.Management.ManagementObjectSearcher("SELECT * FROM Win32_" + alias).Get;

% Get the returned object and convert its contents into a struct.
objEnum = objects.GetEnumerator;
objEnum.MoveNext;
numResultSets = objects.Count;
object = objEnum.Current;
props = object.Properties;

value = cell2struct(cell(numel(field),1), field, 1);
propEnum = props.GetEnumerator;
while propEnum.MoveNext
    tmp = propEnum.Current;
    matches = strcmpi(string(tmp.Name), field);
    if any(matches)
        idx = find(matches,1);
        value.(field{idx}) = tmp.Value;
    end
end

% If looking at processors, set the number of sockets too. Since we
% Should get one result set per socket, this is just the object count.
if strcmpi(alias, "Processor")
    value.NumCPUs = double(numResultSets);
    value.NumberOfCores = double(value.NumberOfCores) * value.NumCPUs;
end

end

%-------------------------------------------------------------------------%
function info = cpuInfoMac()
machdep = callSysCtl( 'machdep.cpu' );
hw = callSysCtl( 'hw' );
kern = callSysCtl( 'kern.hostname' );

% Apple Silicon (even if emulating Intel) no longer reports cache size and
% reports frequency differently.
if strcmp(computer,'MACA64') || ~isfield(machdep, 'cache')
    % Apple Silicon Mac
    maxFreq = 'N/A';
    cacheBytes = str2double(hw.l1dcachesize); % L1 data cache
else
    % Intel Mac
    maxFreq = [num2str(str2double(hw.cpufrequency_max)/1e6),' MHz'];
    cacheBytes = str2double(machdep.cache.size)*1024; % convert from kB
end

info = struct( ...
    'CPUName', machdep.brand_string, ...
    'Clock', maxFreq, ...
    'Cache', cacheBytes, ...
    'TotalMemory', str2double(hw.memsize), ...
    'NumCPUs', 1, ... % No multi-socket Macs that I'm aware of!
    'TotalCores', str2double( machdep.core_count ), ...
    'OSType', getMacOSType(), ...
    'OSVersion', getMacOSVersion(), ...
    'Hostname', kern.kern.hostname );
end

%-------------------------------------------------------------------------%
function info = callSysCtl( namespace )
[~, infostr] = system( sprintf( 'sysctl -a %s', namespace ) );
% Remove the prefix
infostr = strrep( infostr, [namespace,'.'], '' );
% Now break into a structure
infostr = textscan( infostr, '%s', 'delimiter', '\n' );
infostr = infostr{1};
info = struct();
for ii=1:numel( infostr )
    colonIdx = find( infostr{ii}==':', 1, 'first' );
    if isempty( colonIdx ) || colonIdx==1 || colonIdx==length(infostr{ii})
        continue
    end
    % Take care over nested structs
    name = infostr{ii}(1:colonIdx-1);
    value = strtrim(infostr{ii}(colonIdx+1:end));
    if ismember( '.', name )
        % Nested struct. Split the name.
        dotIndex = find( name=='.', 1, 'first' );
        name1 = name(1:dotIndex-1);
        name2 = name(dotIndex+1:end);
        % If we still have nested names, flatten using _.
        name2 = strrep(name2, '.', '_');
        info.(name1).(name2) = value;
    else
        % top-level property
        info.(name) = value;
    end
end
end

%-------------------------------------------------------------------------%
function vernum = getMacOSVersion()
% Extract the OS version number from the system software version output.
[~, vernum] = system('sw_vers -productVersion');
vernum = strtrim(vernum);
end

%-------------------------------------------------------------------------%
function type = getMacOSType()
% Extract the OS type from the system software version output.
[~, type] = system('sw_vers -productName');
type = strtrim(type);
end

%-------------------------------------------------------------------------%
function info = cpuInfoUnix()
txt = readLinuxInfo('/proc/cpuinfo');
cpuinfo = parseLinuxCPUInfoText( txt );

txt = readLinuxInfo('/proc/version');
osinfo = parseLinuxOSInfoText( txt );

txt = readLinuxInfo('/proc/meminfo');
meminfo = parseLinuxMemInfoText( txt );

txt = readLinuxInfo('/proc/sys/kernel/hostname');
hostInfo = parseLinuxHostInfoText( txt );

% Merge the structures
info = cell2struct( [ ...
    struct2cell( cpuinfo )
    struct2cell( meminfo )
    struct2cell( osinfo )
    struct2cell( hostInfo )
    ], [ ...
    fieldnames( cpuinfo )
    fieldnames( meminfo )
    fieldnames( osinfo )
    fieldnames( hostInfo )
    ] );
end

%-------------------------------------------------------------------------%
function info = parseLinuxCPUInfoText( txt )
% Now parse the fields
lookup = {
    'model name',  'CPUName'
    'cpu Mhz',     'Clock'
    'cpu cores',   'CoresPerCPU'
    'physical id', 'NumCPUs'
    'cache size',  'Cache'
    };
info = struct( ...
    'CPUName', {''}, ...
    'Clock', {''}, ...
    'Cache', {''}, ...
    'CoresPerCPU', {[]}, ...
    'NumCPUs', {[]}, ...
    'TotalCores', {[]} );
for ii=1:numel( txt )
    if isempty( txt{ii} )
        continue;
    end
    % Look for the colon that separates the property name from the value
    colon = find( txt{ii}==':', 1, 'first' );
    if isempty( colon ) || colon==1 || colon==length( txt{ii} )
        continue;
    end
    fieldName = strtrim( txt{ii}(1:colon-1) );
    fieldValue = strtrim( txt{ii}(colon+1:end) );
    if isempty( fieldName ) || isempty( fieldValue )
        continue;
    end

    % Is it one of the fields we're interested in?
    idx = find( strcmpi( lookup(:,1), fieldName ) );
    if ~isempty( idx )
        newName = lookup{idx,2};
        info.(newName) = fieldValue;
    end
end

% Convert clock speed
info.Clock = [info.Clock, ' MHz'];

% Convert cache size
info.Cache = parseMemoryValue(info.Cache);

% The number of CPUs is the highest processor ID (+1 since zero-based)
info.NumCPUs = str2double(info.NumCPUs) + 1;
% Convert num cores
info.TotalCores = info.NumCPUs * str2double(info.CoresPerCPU);
info = rmfield(info, 'CoresPerCPU');
end

%-------------------------------------------------------------------------%
function info = parseLinuxOSInfoText( txt )
info = struct( ...
    'OSType', 'Linux', ...
    'OSVersion', '' );
% Find the string "linux version" then look for the bit up to the first
% bracket.
b = extractBetween(txt{1}, 'Linux version ', ' (');
info.OSVersion = b{1};
end

%-------------------------------------------------------------------------%
function info = parseLinuxMemInfoText( txt )
info = struct('TotalMemory', parseMemoryValue(txt, 'MemTotal'));
end

%-------------------------------------------------------------------------%
function info = parseLinuxHostInfoText( txt )
info = struct( 'Hostname', txt{1} );
end

%-------------------------------------------------------------------------%
function bytes = parseMemoryValue(txt, fieldname)
if nargin>1
    txt = txt{startsWith(txt, fieldname)};
end
if isempty(txt)
    bytes = 0;
else
    if endsWith(txt, 'kb', 'ignorecase', true)
        bytesMultiplier = 1024;
    elseif endsWith(txt, 'mb', 'ignorecase', true)
        bytesMultiplier = 1048576;
    elseif endsWith(txt, 'gb', 'ignorecase', true)
        bytesMultiplier = 1073741824;
    else
        bytesMultiplier = 1;
    end
    bytes = str2double(txt(txt>='0' & txt<='9')) * bytesMultiplier;
end
end

%-------------------------------------------------------------------------%
function txt = readLinuxInfo(file)

fid = fopen( file, 'rt' );
if fid<0
    error( 'cpuinfo:BadProcFile', 'Could not open %s for reading', file );
end
cleanup = onCleanup( @() fclose( fid ) );

txt = textscan( fid, '%s', 'Delimiter', '\n' );
txt = txt{1};
end

%{
Copyright (c) 2011-2021 The MathWorks, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without 
modification, are permitted provided that the following conditions are 
met:

* Redistributions of source code must retain the above copyright 
notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright 
notice, this list of conditions and the following disclaimer in 
the documentation and/or other materials provided with the distribution
* Neither the name of the The MathWorks, Inc. nor the names 
of its contributors may be used to endorse or promote products derived 
from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
POSSIBILITY OF SUCH DAMAGE.
%}
