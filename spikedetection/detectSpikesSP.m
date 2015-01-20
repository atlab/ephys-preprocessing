function detectSpikesSP(recFile, channel, outFile)
% Detect all spikes in an SP recording file.
% AE 2011-10-14

% create packetReader for data access
br = baseReader(recFile, sprintf('s1c%d', channel));
filter = filterFactory.createHighpassIIR(2, 600, getSamplingRate(br)); % 2nd order butterworth
fr = filteredReader(br, filter);
pr = packetReader(fr, 1, 'stride', 1e6);

% setup toolchain
sdt = SpikeDetectionToolchain(pr);

% individual steps
threshold = @(sdt) estThresholdSimple(sdt, 'operator', NoOp, 'nParts', 20, 'sigmaThresh', 5);
detection = @(sdt) detectPeak(sdt, 'operator', NoOp);
alignment = @(sdt) alignCOM(sdt,'operator', NoOp, 'searchWin', -10:10, 'upsample', 5, 'peakFrac', 0.5, 'subtractMeanNoise', false);
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
