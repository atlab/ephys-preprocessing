

sdt = SpikeDetectionToolchain;

sdt = addStep(sdt,DefaultThresholdEstimation,'init');
% sdt = addStep(sdt,DetectionThresholdCrossing,'regular');
sdt = addStep(sdt,DetectionPeakAboveThreshold,'regular');
sdt = addStep(sdt,DefaultSpikeExtraction,'regular');
sdt = addStep(sdt,DefaultSpikeAlignment,'regular');
sdt = addStep(sdt,DefaultSpikeExtraction,'regular');
sdt = addStep(sdt,SaveData,'post');

% sdt = setParams(sdt,'tstart',426884,'tend',2788255);
% sdt = setParams(sdt,'tstart',426884,'tend',13788255);
% sdt = setParams(sdt,'istart',1,'iend',1e6+9);
sdt = setParams(sdt,'sigmaThresh',5);
% sdt = setParams(sdt,'freqBand',[500 700 5800 6000]);

% fileName = 'Y:\hammer\Hulk\2008-08-18_11-35-36\08_18_2008_12_18_39\neuro%d';
%fileName = '/stor01/hammer/Hulk/2008-08-12_10-43-45/08_12_2008_11_33_34/neuro%d';
fileName = '/stor02/hammer/Andy/2009-02-17_13-50-11/02_17_2009_14_47_34/neuro%d';

sdt = init(sdt,'fileName',getLocalPath(fileName),'tetrode',10);

data = run(sdt)
