function artifacts = detectSpikesUtah(recFile, electrode, outFile)
% Detect all spikes in a utah channel.
%   This is an improved version that automatically removes noise segments
%   in the data, which sometimes occurs at the beginning and the end of
%   recordings if the preamps are turned off. It also fixes a minor issue
%   in a previous version where many spikes were detected multiple times at
%   slightly offset points in time.
%
% AE 2012-11-09
% JC 2013-05-08

% get the raw channel and reference data
br = baseReader(recFile);
names = getChannelNames(br); 
rawChannel = baseReader(recFile, names{electrode}); % modified to accept old format - EYW 8/29/2014
%rawChannel = baseReader(recFile, sprintf('Electrode%02d', electrode));

refFile = fullfile(fileparts(recFile),'ref%d');
ref = baseReader(refFile);

% create packetReader for data access
br = baseReaderReferenced(rawChannel, ref);
filter = filterFactory.createBandpass(400, 600, 5800, 6000, getSamplingRate(br));
fr = filteredReader(br, filter);
pr = packetReader(fr, 1, 'stride', 1e6);

% setup toolchain
sdt = SpikeDetectionToolchain(pr);

% individual steps
alignSignal = SignedVectorNorm('p', 2);

threshold = @(sdt) estThresholdPerChannel(sdt, 'nParts', 20, 'sigmaThresh', 5);
detection = @(sdt) detectPeakExcludeNoise(sdt);
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
close(br);

% return periods of noise artifacts
artifacts = getGlobalData(sdt, 'noiseArtifacts');
