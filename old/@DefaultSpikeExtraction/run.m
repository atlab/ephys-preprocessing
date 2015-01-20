function data = run(se,data)
% Extract spikes
% AE 2009-02-26

% parameters
ctPoint = data.params.ctPoint;
windowSize = data.params.windowSize;
win = (1:windowSize) - ctPoint;
pad = 3;
iWin = (1-pad:windowSize+pad) - ctPoint;

% spike times (in samples)
spikes = data.chunks(end).spikeSamples;

% waveforms
wave = data.current.waveform;
nChans = size(wave,2);

% We need to trash spikes too close to the edges of the chunk of data we're
% working on. This should be a very, very tiny fraction, though since the
% chunks are large.
n = size(wave,1);
spikes(spikes < ctPoint+pad | spikes > n-windowSize+ctPoint-pad) = [];
data.chunks(end).spikeSamples = spikes;

% extract spikes
nSpikes = numel(spikes);
w = zeros([windowSize,nSpikes,nChans]);

% do we need to interpolate or do we have integer locations?
if any(round(spikes) ~= spikes)
    for i = 1:nChans
        % samples to extract (window relative to detected spike)
        xi = bsxfun(@plus,rem(spikes,1),win);
        x = bsxfun(@plus,fix(spikes),iWin)';

        % extract samples by cubic spline interpolation (use a custom
        % vectorized interpolation routine)
        w(:,:,i) = interpcus(iWin,reshape(wave(x,i),size(x)),xi);       % private/interpcus
    end
else
    ndx = bsxfun(@plus,spikes,win)';
    w = wave(ndx(:),:);
    w = reshape(w,[windowSize,nSpikes,nChans]);
end

data.chunks(end).spikeWaveforms = w;

% extract times
Fs = data.params.Fs;
subsample = rem(spikes,1);
t = data.current.time(fix(spikes)) + subsample * 1000/Fs;
data.chunks(end).spikeTimes = t;
