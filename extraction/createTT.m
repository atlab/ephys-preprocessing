function sdt = createTT(sdt, outFile)
% Create tt structure.
%   sdt = createTT(sdt, outFile)
%
% Updated: AE 2011-10-14
% Initial: AE 2009-03-27

assert(nargin == 2 && ~isempty(outFile), 'No output file specified!')

% check if spikes were aligned
aligned = false;
if isGlobalData(sdt,'aligned') && getGlobalData(sdt,'aligned')
    aligned = true;
end

% collect spike times and waveforms into tt structure
nChans = getNbChannels(getReader(sdt));
tt = struct('t',[],'w',{cell(1,nChans)},'aligned',aligned);

t = getChunkData(sdt,'spikeTimes');
w = getChunkData(sdt,'spikeWaveforms');

tt.t = t(:);
for j = 1:nChans
    tt.w{j} = w(:,:,j);
end

% create spike height field
tt.h = zeros(size(tt.w{1},2),nChans);
if ~isempty(tt.h)
    for i = 1:nChans
        tt.h(:,i) = max(tt.w{i}) - min(tt.w{i});
    end
end

% % HACK: put overlap info into tt struct
% overlap = getChunkData(sdt,'spikeOverlaps');
% tt.w{1}(1,overlap) = NaN;

% write to disk
if isFirstChunk(sdt)
    ah_writeTT_HDF5(outFile, tt);
else
    ah_appendTT_HDF5(outFile, tt);
end
