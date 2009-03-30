function data = run(sd,data)
% Detect spikes based on finding all local maxima above threshold.
% AE 2009-03-01

% Work on distance to origin to detect local maxima
%   To find local maxima, all channels should be taken into account. Peaks
%   might be slightly shifted on different channels. If two channels have
%   similar amplitudes but the peaks occur at different points in time,
%   then spikes would ranmdomly get aligned to one peak or the other
%   depending on the noise.
w = data.current.waveform;
wr = sqrt(sum(w.^2,2));

% Since spikes might only be visible on one channel, we consider every 
%   local maximum where at least one channel is above threshold as a 
%   putative spike.
above = any(bsxfun(@gt,w,data.threshold),2);

% Detect spikes
dw = diff(wr);
t = find(above(2:end-1) & dw(1:end-1) > 0 & dw(2:end) <= 0) + 1;
data.chunks(end).spikeSamples = t;
