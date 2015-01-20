function sdt = estThresholdSimple(sdt, varargin)
% Simple threshold estimation by taking median absolute deviation.
% AE 2011-10-14

params.nParts = 20;
params.operator = VectorNorm('p', Inf); % max of channels (i.e. any channel) above threshold
params.sigmaThresh = 5;
params = parseVarArgs(params, varargin{:});

fprintf('Estimating threshold for spike detection...\n')

% make sure it's deterministic
rand('state', 62374)
randn('state', 62374)

% # chunks in this data set
reader = getReader(sdt);
nChunks = size(reader, 1);

% randomly select some chunks of data
nParts = params.nParts;
r = randperm(nChunks);
chunks = r(1:min(nParts,nChunks));
nChunks = numel(chunks);

% estimate noise distribution
sd = zeros(nChunks, 1);
m = sd;
for j = 1:nChunks
    x = -toMuV(reader, reader(chunks(j)));
    x = apply(params.operator, x);
    m(j) = median(x);
    sd(j) = median(abs(x - m(j))) / 0.6745;
end

% threshold
threshold = median(m) + params.sigmaThresh * median(sd);
sdt = setGlobalData(sdt, 'threshold', threshold);
sdt = setGlobalData(sdt, 'noiseMean', m);
sdt = setGlobalData(sdt, 'noiseStd', sd);

fprintf('  Determined threshold is %.1f muV\n', threshold)
