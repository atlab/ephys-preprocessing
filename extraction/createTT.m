function sdt = createTT(sdt,varargin)
% Create tt structure.
%   sdt = createTT(sdt,varargin)
%
% AE 2009-03-27

outDir = getParams(sdt,'outDir');
assert(~isempty(outDir),'No output directory specified!')

% check if spikes were aligned
aligned = false;
if isGlobalData(sdt,'aligned') && getGlobalData(sdt,'aligned')
    aligned = true;
end

% collect spike times and waveforms into tt structure
nChans = getNbChannels(getRawStream(sdt));
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
tet = getParams(sdt,'tetrode');
fileName = fullfile(getLocalPath(outDir),sprintf('Sc%u.Htt',tet));
if isFirstChunk(sdt)
    ah_writeTT_HDF5(fileName,tt);
else
    ah_appendTT_HDF5(fileName,tt);
end
