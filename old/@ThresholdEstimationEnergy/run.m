function data = run(te,data)
% Estimate spike detection threshold for energy-based detection.
%   Estimates the standard deviation of the noise in a recording by fitting
%   a Gaussian on the part of the distribution close to mean
%
% AE 2009-03-08

fprintf('Estimating energy noise amplitude...\n')

% make sure it's deterministic
rand('state',62374)
randn('state',62374)

% set up packetReader to get some random chunks of data
partSize = data.params.estPartSize;
packRec = packetReader(data.filtered,[1 2],'stride',[partSize 1]);

% # chunks in this data set
istart = data.params.istart;
iend = data.params.iend;
chunkStart = ceil(istart / partSize) + 1;
chunkEnd   = floor(iend  / partSize);
chunks = chunkStart:chunkEnd;
nChunks = numel(chunks);

% randomly select some chunks of data
nParts = data.params.nEstParts;
r = randperm(nChunks);
r = r(1:min(nParts,nChunks));
chunks = chunks(r);
nChunks = numel(chunks);

% estimate SD of noise
par = zeros(nChunks,2);
for j = 1:nChunks
    wave = packRec(chunks(j),:);
    par(j,:) = getDistr(te,wave,data.params.energyWin);
end

% threshold
data.threshold = median(par(:,1)) + data.params.sigmaThresh * median(par(:,2));

fprintf('  Determined threshold is %.1f muV\n',data.threshold/2^23*317e3)
