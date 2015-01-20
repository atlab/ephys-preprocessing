% Energy-based spike detection
% AE 2009-03-08

% set up data processing
teo = SmoothedTEO('smooth',5,'sqrt',true);

% set up functions
threshold = @(sdt) estThreshold(sdt,'operator',teo,'partSize',1e5,'nParts',20,'sigmaThresh',9);
detection = @(sdt) detectPeak(sdt,'operator',teo);
alignment = @(sdt) alignPeak(sdt,'operator',teo,'searchWin',0,'upsample',5);
extraction = @(sdt) extract(sdt,'ctPoint',12,'windowSize',40);

% set up toolchain
sdt = SpikeDetectionToolchain;

sdt = addStep(sdt,threshold,'init');
sdt = addStep(sdt,detection,'regular');
sdt = addStep(sdt,alignment,'regular');
sdt = addStep(sdt,extraction,'regular');
sdt = addStep(sdt,@createTT,'post');

sdt = setParams(sdt,'tstart',426884,'tend',1088255);
sdt = setParams(sdt,'tstart',426884,'tend',588255);
% sdt = setParams(sdt,'tstart',426884,'tend',13788255);
% sdt = setParams(sdt,'istart',1,'iend',1e6+9);
sdt = setParams(sdt,'partSize',2e5,'outDir','/mnt/lab/users/alex/tmp/detection');

fileName = 'X:\hammer\Hulk\2008-08-12_10-43-45\08_12_2008_11_33_34\neuro%d';
% fileName = '/stor02/hammer/Hulk/2008-08-12_10-43-45/08_12_2008_11_33_34/neuro%d';
% fileName = '/stor02/hammer/Andy/2009-02-17_13-50-11/02_17_2009_14_47_34/neuro%d';

sdt = init(sdt,'fileName',getLocalPath(fileName),'tetrode',14);

sdt = run(sdt)
