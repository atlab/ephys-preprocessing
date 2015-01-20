function data = run(te,data)
% Estimate spike detection threshold
%   Estimates the standard deviation of the noise in a recording by fitting
%   a Gaussian on the part of the distribution close to mean
%
% AE 2009-02-26

fprintf('Estimating noise amplitude...\n')

% make sure it's deteministic
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
nChans = getNbChannels(data.raw);
sigma = zeros(nChans,nChunks);
fprintf('  channel')
for i = 1:nChans
    fprintf(' %d',i)
    for j = 1:nChunks
        wave = packRec(chunks(j),i);
        sigma(i,j) = getSigma(te,wave);
    end
end
fprintf('\n')

% threshold
data.threshold = data.params.sigmaThresh * median(sigma,2)';
