function varargout = run(sdt)
% Run spike detection toolchain.
%   tt = run(sdt)
%
% AE 2009-02-24

fprintf('Starting spike detection\n')

% Run initialization steps
for i = 1:numel(sdt.steps.init)
    sdt = sdt.steps.init{i}(sdt);
end

% determine number of chunks
istart = getStartIndex(sdt);
iend = getEndIndex(sdt);
partSize = min(getParams(sdt,'partSize'),iend - istart + 1);
packRec = packetReader(sdt.filtered,[1 2],'stride',[partSize 1]);

chunkStart = floor(istart / partSize) + 1;
chunkEnd = ceil(iend / partSize);
chunks = chunkStart:chunkEnd;
nChunks = numel(chunks);

% process chunks individually
fprintf('Processing %d chunks of data\n',nChunks)
sdt.chunks = struct('spikeTimes',{});
pp = 0;
for i = 1:nChunks
    
    % read current filtered waveform chunk
    sdt.current.waveform = packRec(chunks(i),:);
    sdt.current.time = packRec(chunks(i)).t;

    % run individual steps
    sdt.chunks(i).spikeTimes = [];
    for j = 1:numel(sdt.steps.regular)
        sdt = sdt.steps.regular{j}(sdt);
    end
    
    % empty signal cache
    sdt.cache = struct;
    
    % progress output
    p = i/nChunks * 100;
    if fix(p) > pp
        fprintf('  %.1f%%\n',p)
    end
    pp = p;
end

% run post-processing steps
for i = 1:numel(sdt.steps.post)
    sdt = sdt.steps.post{i}(sdt);
end

if nargout > 0
    varargout{1} = sdt;
end
