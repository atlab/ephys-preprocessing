function sdt = SpikeDetectionToolchain(packetReader)

par.Fs = getSamplingRate(packetReader);   % sampling rate
sdt.params = par;

% data access
sdt.reader = packetReader;

% current chunk of data we're working on
sdt.current = struct('waveform',[],'time',[]);

% temporary cache for time-consuming operations
sdt.cache = struct;

% data to be stored for each chunk
sdt.chunks = struct('spikeTimes',{});

% global data to be stored
sdt.global = struct;

% processing steps
sdt.steps = struct('init',{{}},'regular',{{}},'post',{{}});

sdt = class(sdt,'SpikeDetectionToolchain');
