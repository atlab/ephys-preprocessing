function artifacts = detectSpikesMultiChannelProbes(reader, outFile)
% Detect all spikes in a multi-channel recording file.

% create packetReader for data access
filter = filterFactory.createBandpass(400, 600, 5800, 6000, getSamplingRate(reader));
fr = filteredReader(reader, filter);
pr = packetReader(fr, 1, 'stride', 1e6);

% setup toolchain
sdt = SpikeDetectionToolchain(pr);

% individual steps
alignSignal = RectifiedVectorNorm('p', 2);

threshold = @(sdt) estThresholdPerChannel(sdt, 'nParts', 20, 'sigmaThresh', 5);
detection = @(sdt) detectCentralPeakExcludeNoise(sdt);
alignment = @(sdt) alignCOM(sdt, 'operator', alignSignal, 'searchWin', -10:10, 'upsample', 5, 'peakFrac', 0.5, 'subtractMeanNoise', false);
removal = @(sdt) removeDoubles(sdt, 'refrac', 0.3);
extraction = @(sdt) extract(sdt, 'ctPoint', 10, 'windowSize', 28);
saving = @(sdt) createTT(sdt, outFile);

sdt = addStep(sdt, threshold, 'init');
sdt = addStep(sdt, detection, 'regular');
sdt = addStep(sdt, alignment, 'regular');
sdt = addStep(sdt, removal, 'regular');
sdt = addStep(sdt, extraction, 'regular');
sdt = addStep(sdt, saving, 'regular');

sdt = setGlobalData(sdt, 'noiseArtifacts', zeros(0, 2));

% run it
run(sdt);                                                            

% cleanup
close(reader);

% return periods of noise artifacts
artifacts = getGlobalData(sdt, 'noiseArtifacts');
