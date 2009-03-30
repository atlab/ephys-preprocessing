function sdt = createTT(sdt,varargin)
% Create tt structure.
%   sdt = createTT(sdt,varargin)
%
% AE 2009-03-27

% check if spikes were aligned
aligned = false;
if isGlobalData(sdt,'aligned') && getGlobalData(sdt,'aligned')
    aligned = true;
end

% collect spike times and waveforms into tt structure
nChans = getNbChannels(getRawStream(sdt));
tt = struct('t',[],'w',{cell(1,nChans)},'aligned',aligned);
chunks = getChunks(sdt);
for i = 1:numel(chunks)
    tt.t = [tt.t; reshape(chunks(i).spikeTimes,[],1)];
    for j = 1:nChans
        w = chunks(i).spikeWaveforms(:,:,j);
        tt.w{j} = [tt.w{j}, w];
    end
end

% create spike height field
tt.h = zeros(size(tt.w{1},2),nChans);
for i = 1:nChans
    tt.h(:,i) = max(tt.w{i}) - min(tt.w{i});
end

sdt = setGlobalData(sdt,'tt',tt);

% save data to disk
outDir = getParams(sdt,'outDir');
if ~isempty(outDir)
    tet = getParams(sdt,'tetrode');
    fileName = fullfile(getLocalPath(outDir),sprintf('Sc%u.Htt',tet));
    fprintf('Writing data to %s\n',fileName)
    ah_writeTT_HDF5(fileName,tt);
end
