function sdt = init(sdt,varargin)
% Initialize SpikeDetectionToolchain.
%   sdt = init(sdt,'params',values,...)
%
% AE 2009-02-24

% set parameters
sdt = setParams(sdt,varargin{:});

% Make sure all relevant parameters are set
[fileName,tetrode] = getParams(sdt,'fileName','tetrode');
assert(~isempty(fileName),'Parameter ''fileName'' must be set!')
assert(~isempty(tetrode),'Parameter ''tetrode'' must be set!')

% Make sure file exists
file = strrep(fileName,'neuro%d','neuro0');
assert(exist(file,'file') ~= 0,'Could not find neural data file: %s',file)

% Set up raw data stream
sdt.raw = baseReader(fileName,tetrode);
Fs = getSamplingRate(sdt.raw);
sdt = setParams(sdt,'Fs',Fs);

% Set up filtered data stream
if isempty(sdt.filter)
    freqBand = num2cell(getParams(sdt,'freqBand'));
    sdt.filter = filterFactory.createBandpass(freqBand{:},Fs);
elseif isnumeric(sdt.filter)
    sdt.filter = waveFilter(sdt.filter,Fs);
end
sdt.filtered = filteredReader(sdt.raw,sdt.filter);

% start and end
sdt = setParams(sdt,'istart',getStartIndex(sdt),'iend',getEndIndex(sdt));
