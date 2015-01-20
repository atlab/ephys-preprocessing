% Energy-based spike detection
% AE 2009-03-08

sdt = SpikeDetectionToolchain;

sdt = addStep(sdt,ThresholdEstimationEnergy,'init');
sdt = addStep(sdt,DetectionEnergy,'regular');
sdt = addStep(sdt,AlignmentEnergy,'regular');
sdt = addStep(sdt,DefaultSpikeExtraction,'regular');
sdt = addStep(sdt,SaveData,'post');

win = gausswin(13,6);
win = win(5:end) + win(1:end-4);
win = conv(win,gausswin(7,2));
win = win/sum(win);
sdt = setParams(sdt,'energyWin',win);

sdt = setParams(sdt,'tstart',426884,'tend',1088255);
% sdt = setParams(sdt,'tstart',426884,'tend',13788255);
% sdt = setParams(sdt,'istart',1,'iend',1e6+9);
sdt = setParams(sdt,'sigmaThresh',5,'outDir',getLocalPath('/lab/users/alex/tmp/detection'));
sdt = setParams(sdt,'partSize',1e6);
% sdt = setParams(sdt,'freqBand',[500 700 5800 6000]);

fileName = 'X:\hammer\Hulk\2008-08-12_10-43-45\08_12_2008_11_33_34\neuro%d';
% fileName = '/stor02/hammer/Hulk/2008-08-12_10-43-45/08_12_2008_11_33_34/neuro%d';
% fileName = '/stor02/hammer/Andy/2009-02-17_13-50-11/02_17_2009_14_47_34/neuro%d';

sdt = init(sdt,'fileName',getLocalPath(fileName),'tetrode',20);

data = run(sdt)
