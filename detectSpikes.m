function detectSpikes(recDirectory,tetrode,outDir,varargin)
% Energy-based spike detection
% AE 2009-03-28

args.sigmaThresh = 11;
args = parseVarArgs(args,varargin{:});

% set up data processing
teo = SmoothedTEO('smooth',5,'sqrt',true);

% set up functions
threshold = @(sdt) estThreshold(sdt,'operator',teo,'partSize',1e5,'nParts',20,'sigmaThresh',args.sigmaThresh);
detection = @(sdt) detectPeak(sdt,'operator',teo);
alignment = @(sdt) alignPeak(sdt,'operator',teo,'searchWin',0,'upsample',5);
extraction = @(sdt) extract(sdt,'ctPoint',9,'windowSize',28);

% set up toolchain
sdt = SpikeDetectionToolchain;

sdt = addStep(sdt,threshold,'init');
sdt = addStep(sdt,detection,'regular');
sdt = addStep(sdt,alignment,'regular');
sdt = addStep(sdt,extraction,'regular');
sdt = addStep(sdt,@createTT,'post');

% set parameters
sdt = setParams(sdt,'partSize',2e5);
sdt = setParams(sdt,varargin{:});
fileName = fullfile(getLocalPath(recDirectory),'neuro%d');
sdt = setParams(sdt,'fileName',fileName,'tetrode',tetrode,'outDir',outDir);

% intialize and run
sdt = init(sdt);
sdt = run(sdt);
