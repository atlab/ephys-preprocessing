function data = run(sd,data)
% Detect spikes
% AE 2009-02-26

% find segments above threshold
w = data.current.waveform;
above = any(bsxfun(@gt,w,data.threshold),2);

% detect trehsold crossings from below
data.chunks(end).spikeSamples = find(above(2:end) & ~above(1:end-1)) + 1;
