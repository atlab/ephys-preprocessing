function varargout = run(sdt)
% Run spike detection toolchain.
%   sdt = run(sdt)
%
% Updated: AE 2011-10-14
% Initial: AE 2009-02-24

fprintf('Starting spike detection\n')

% Run initialization steps
for i = 1:numel(sdt.steps.init)
    sdt = sdt.steps.init{i}(sdt);
end

% determine number of chunks
nChunks = size(sdt.reader, 1);

% process chunks individually
fprintf('Processing %d chunks of data\n',nChunks)
sdt.chunks = struct('spikeTimes',{});
for i = 1:nChunks
    
    % read current filtered waveform chunk (flip so peaks are upwards)
    sdt.current.waveform = -toMuV(sdt.reader, sdt.reader(i));
    sdt.current.time = reshape(sdt.reader(i).t, [], 1);
    sdt.current.chunk = i;

    % run individual steps
    sdt.chunks(i).spikeTimes = [];
    for j = 1:numel(sdt.steps.regular)
        sdt = sdt.steps.regular{j}(sdt);
    end
    
    % empty signal cache
    sdt.cache = struct;
    
    % progress output
    progress(i, nChunks, 20);
end

% run post-processing steps
for i = 1:numel(sdt.steps.post)
    sdt = sdt.steps.post{i}(sdt);
end

if nargout > 0
    varargout{1} = sdt;
end
