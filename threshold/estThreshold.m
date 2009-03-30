function sdt = estThreshold(sdt,varargin)

params.partSize = 1e5;
params.nParts = 20;
params.operator = SmoothedTEO;
params.sigmaThresh = 5;
params = parseVarArgs(params,varargin{:});

fprintf('Estimating threshold for spike detection...\n')

% make sure it's deterministic
rand('state',62374)
randn('state',62374)

% set up packetReader to get some random chunks of data
partSize = params.partSize;
packRec = packetReader(getFilteredStream(sdt),[1 2],'stride',[partSize 1]);

% # chunks in this data set
[istart,iend] = getParams(sdt,'istart','iend');
chunkStart = ceil(istart / partSize) + 1;
chunkEnd   = floor(iend  / partSize);
chunks = chunkStart:chunkEnd;
nChunks = numel(chunks);

% randomly select some chunks of data
nParts = params.nParts;
r = randperm(nChunks);
r = r(1:min(nParts,nChunks));
chunks = chunks(r);
nChunks = numel(chunks);

% estimate noise distribution
par = zeros(nChunks,3);
for j = 1:nChunks
    x = packRec(chunks(j),:);
    x = apply(params.operator,x);
    par(j,:) = capfit(x);
end

% threshold
threshold = median(par(:,3)) + params.sigmaThresh * median(par(:,3));
sdt = setGlobalData(sdt,'threshold',threshold);

fprintf('  Determined threshold is %.1f muV\n',threshold/2^23*317e3)
