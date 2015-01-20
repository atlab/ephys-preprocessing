% Energy-based spike detection
% AE 2009-03-08

% set up data processing
teo = SmoothedTEO('smooth',5,'sqrt',true);
vec = VectorNorm('p',5);

% set up functions
threshold = @(sdt) estThreshold(sdt,'operator',teo,'partSize',1e5,'nParts',20,'sigmaThresh',9);
detection = @(sdt) detectPeak(sdt,'operator',teo);
alignment = @(sdt) alignCOM(sdt,'operator',vec,'searchWin',-10:10,'upsample',5,'peakFrac',0.5,'subtractMeanNoise',false);
selection = @(sdt) selectClean(sdt);
extraction = @(sdt) extract(sdt,'ctPoint',20,'windowSize',50);
saving = @createTT;

% set up toolchain
sdt = SpikeDetectionToolchain;

sdt = addStep(sdt,threshold,'init');
sdt = addStep(sdt,detection,'regular');
sdt = addStep(sdt,alignment,'regular');
sdt = addStep(sdt,extraction,'regular');
sdt = addStep(sdt,selection,'regular');
sdt = addStep(sdt,saving,'regular');

t = 15419291;
sdt = setParams(sdt,'tstart',t,'tend',t+10*60*1000);
sdt = setParams(sdt,'partSize',2e5,'outDir','/mnt/lab/users/alex/tmp/detection');

fileName = 'X:\hammer\Hulk\2008-08-12_10-43-45\08_12_2008_11_33_34\neuro%d';

sdt = init(sdt,'fileName',getLocalPath(fileName),'tetrode',4);

sdt = run(sdt)
