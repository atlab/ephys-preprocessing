function detectSpikesTetrodes(recFile, tetrode, outFile)
% Detect all spikes in a tetrode recording file.
% AE 2011-10-14

% create packetReader for data access
br = baseReader(recFile, sprintf('t%dc*', tetrode));
filter = filterFactory.createBandpass(400, 600, 5800, 6000, getSamplingRate(br));
fr = filteredReader(br, filter);
pr = packetReader(fr, 1, 'stride', 1e6);

% setup toolchain
sdt = SpikeDetectionToolchain(pr);

% individual steps
detectSignal = VectorNorm('p', Inf);
alignSignal = VectorNorm('p', 2);

threshold = @(sdt) estThresholdSimple(sdt, 'operator', detectSignal, 'nParts', 20, 'sigmaThresh', 5);
detection = @(sdt) detectPeak(sdt, 'operator', detectSignal);
alignment = @(sdt) alignCOM(sdt,'operator', alignSignal, 'searchWin', -10:10, 'upsample', 5, 'peakFrac', 0.5, 'subtractMeanNoise', false);
extraction = @(sdt) extract(sdt, 'ctPoint', 10, 'windowSize', 28);
saving = @(sdt) createTT(sdt, outFile);

sdt = addStep(sdt, threshold, 'init');
sdt = addStep(sdt, detection, 'regular');
sdt = addStep(sdt, alignment, 'regular');
sdt = addStep(sdt, extraction, 'regular');
sdt = addStep(sdt, saving, 'regular');

% run it
run(sdt);                                                            

% cleanup
close(br);
