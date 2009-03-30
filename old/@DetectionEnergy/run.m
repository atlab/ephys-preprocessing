function data = run(sd,data)
% Energy-based spike detection.
% AE 2009-03-27

% energy via Teager Energy Operator
w = TEO(data.current.waveform);

% smooth
k = getParams(sd,'smooth');
win = gausswin(2*k+1);
win = win / sum(win);
w = conv(w,win);
w = w(k+1:end-k);
data.current.energy = w;

% Detect spikes
dw = diff(w);
s = find(w(2:end-1) > data.threshold & dw(1:end-1) > 0 & dw(2:end) <= 0) + 1;
data.chunks(end).spikeSamples = s;

fprintf('  Detected %d spikes\n',numel(s))
