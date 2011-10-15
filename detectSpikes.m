function detectSpikes(recDirectory,tetrode,outDir,varargin)
% Energy-based spike detection
% AE 2009-04-03

args.sigmaThresh = 10;
args = parseVarArgs(args,varargin{:});

% set up data processing
teo = SmoothedTEO('smooth',5,'sqrt',true);
vec = VectorNorm('p',5);

% set up functions
threshold = @(sdt) estThreshold(sdt,'operator',teo,'partSize',1e5,'nParts',20,'sigmaThresh',args.sigmaThresh);
detection = @(sdt) detectPeak(sdt,'operator',teo);
alignment = @(sdt) alignCOM(sdt,'operator',vec,'searchWin',-10:10,'upsample',5,'peakFrac',0.5,'subtractMeanNoise',false);
extraction = @(sdt) extract(sdt,'ctPoint',15,'windowSize',40);
saving = @createTT;

% set up toolchain
sdt = SpikeDetectionToolchain;

sdt = addStep(sdt,threshold,'init');
sdt = addStep(sdt,detection,'regular');
sdt = addStep(sdt,alignment,'regular');
sdt = addStep(sdt,extraction,'regular');
sdt = addStep(sdt,saving,'regular');

% set parameters
sdt = setParams(sdt,'partSize',1e6);
sdt = setParams(sdt,varargin{:});
fileName = fullfile(getLocalPath(recDirectory),'neuro%d');
sdt = setParams(sdt,'fileName',fileName,'tetrode',tetrode,'outDir',outDir);

% intialize and run
sdt = init(sdt);
sdt = run(sdt);                                                            %#ok<NASGU>
