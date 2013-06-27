function sdt = extract(sdt,varargin)
% Extract spike waveforms.
%   sdt = extract(sdt)
%
% AE 2009-03-27

% parameters
params.ctPoint = 12;
params.windowSize = 40;
params = parseVarArgs(params,varargin{:});

ctPoint = params.ctPoint;
windowSize = params.windowSize;
win = (1:windowSize) - ctPoint;
pad = 3;
iWin = (1-pad:windowSize+pad) - ctPoint;

% spike times (in samples)
spikes = getCurrentData(sdt,'spikeSamples');

% waveforms
wave = getCurrentWaveform(sdt);
nChans = size(wave,2);

% We need to trash spikes too close to the edges of the chunk of data we're
% working on. This should be a very, very tiny fraction, though since the
% chunks are large.
n = size(wave,1);
spikes(spikes < ctPoint+pad | spikes > n-windowSize+ctPoint-pad) = [];
sdt = setCurrentData(sdt,'spikeSamples',spikes);
% TODO: somehow keep track of what was trashed...

% extract spikes
nSpikes = numel(spikes);
w = zeros([windowSize,nSpikes,nChans]);

% do we need to interpolate or do we have integer locations?
subsample = rem(spikes,1);
if any(subsample ~= 0)
    for i = 1:nChans
        % samples to extract (window relative to detected spike)
        xi = bsxfun(@plus,subsample,win);
        x = bsxfun(@plus,fix(spikes),iWin)';

        % extract samples by cubic spline interpolation (use a custom
        % vectorized interpolation routine)
        w(:,:,i) = interpcus(iWin,reshape(wave(x,i),size(x)),xi);
    end
else
    if isempty(spikes)
        w = [];
    else
        ndx = bsxfun(@plus,spikes,win)';
        w = wave(ndx(:),:);
        w = reshape(w,[windowSize,nSpikes,nChans]);
    end
end

% store waveforms
sdt = setChunkData(sdt,'spikeWaveforms',w);

% extract times
Fs = getParams(sdt,'Fs');
t = getCurrentTime(sdt);
if ~isempty(spikes)
    t = t(fix(spikes)) + subsample * 1000 / Fs;
else
    t = [];
end
sdt = setChunkData(sdt,'spikeTimes',t);
