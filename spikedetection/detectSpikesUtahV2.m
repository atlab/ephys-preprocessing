function artifacts = detectSpikesUtahV2(recFile, electrode, outFile)
% Detect all spikes in a Utah channel.
%   Compared to the version 1 of detectSpikesUtah, this one utilizes
%   detection threshold of 4.5 standard deviations as opposed to the 5.

% get the raw channel and reference data
% modified how names are called to make compatible with Woody's old data
brraw = baseReader(recFile);
switch class(brraw)
    case 'baseReaderElectrophysiology'
        rawChannel = baseReader(recFile, sprintf('Electrode%02d', electrode));
    case 'baseReaderHammer'
        tt = ceil(electrode / 4);
        ch = rem(electrode - 1, 4) + 1;
        rawChannel = baseReader(recFile, sprintf('t%dc%d', tt, ch));
    otherwise
        error('Dont''t know this file type. HELP!!!')
end

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

threshold = @(sdt) estThresholdPerChannel(sdt, 'nParts', 20, 'sigmaThresh', 4.5); % change here for threshold sigma setting?
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
