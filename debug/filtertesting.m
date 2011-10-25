
file = 'M:\Hulk\2011-10-22_22-09-09\2011-10-22_22-09-15\Electrophysiology%d.h5';
br = baseReader(file, 's1c*');
bandpass = filterFactory.createBandpass(400, 600, 5800, 6000, getSamplingRate(br));
frBp = filteredReader(br, bandpass);
highpass = filterFactory.createHighpass(400, 600, getSamplingRate(br));
frHp = filteredReader(br, highpass);
iir = filterFactory.createBandpassIIR(2, 600, 6000, getSamplingRate(br));
frIIR = filteredReader(br, iir);

% butterworth IIR filter
n = 2;
cutoff = 600;
Wn = cutoff / getSamplingRate(br) * 2;
[b, a] = butter(n, Wn, 'high');


%% read and filter data / detect spikes
t0 = 1538815;
x = br(getSampleIndex(br, t0)+(1:1e7),5) * 1e6;
xBp = frBp(getSampleIndex(frBp, t0)+(1:1e7),5) * 1e6;
xHp = frHp(getSampleIndex(frBp, t0)+(1:1e7),5) * 1e6;
xIIR = filter(b, a, x);
xIIR2 = frIIR(getSampleIndex(frIIR, t0)+(1:1e7),5) * 1e6;
thresh = -500;
ndx = find(xBp(1:end-1) > thresh & xBp(2:end) < thresh);
win = -320:320;
ndx = bsxfun(@plus, ndx, win);
w = x(ndx);
wBp = xBp(ndx);
wHp = xHp(ndx);
wIIR = xIIR(ndx);
wIIR2 = xIIR2(ndx);


%% plot average waveforms
figure
t = win / 32e3;
plot(t, mean(w) - mean(w(:)), 'k', t, mean(wBp), 'r', t, mean(wHp), 'b', t, mean(wIIR), 'g', t, mean(wIIR2), 'm')
grid


