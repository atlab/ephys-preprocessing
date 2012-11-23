function sdt = estThresholdPerChannel(sdt, varargin)
% Simple threshold estimation by taking median absolute deviation.
%   Threshold is estimated per channel.
%
% AE 2012-11-09

params.nParts = 20;
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
for j = 1:nChunks
    x = -reader(chunks(j));
    k = size(x, 2);
    sd(j, 1:k) = median(abs(x), 1) / 0.6745;
end

% threshold
threshold = params.sigmaThresh * median(sd, 1);
sdt = setGlobalData(sdt, 'threshold', threshold);
sdt = setGlobalData(sdt, 'noiseStd', sd);

fprintf('  Determined threshold is %.1f muV\n', toMuV(reader, threshold))
