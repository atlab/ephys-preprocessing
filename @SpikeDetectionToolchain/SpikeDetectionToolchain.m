function sdt = SpikeDetectionToolchain(varargin)

% copy constructor
if nargin > 0 && isa(varargin{1},'SpikeDetectionToolchain')
    sdt = varargin{1};
    return
end

par.fileName = '';      % name of continuous neural data file
par.tetrode = '';       % tetrode
par.outDir = '';        % directory where output is written
par.Fs = [];            % sampling rate
par.istart = [];        % start of segment [sample index]
par.tstart = [];        %                  [time]
par.iend = [];          % end of segment [sample index]
par.tend = [];          %                [time]
par.partSize = 1e7;     % partition size
par.freqBand = [400 600 5800 6000];	% frequency band for bandpass filter
% par.refractory = 0.8;	% refractory period [ms]
sdt.params = par;

% raw data
sdt.raw = [];       % raw data stream
sdt.filtered = [];  % filtered data stream
sdt.filter = [];    % waveFilter

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
