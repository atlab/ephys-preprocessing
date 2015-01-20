function data = run(sd,data)

% check if spikes were aligned
aligned = false;
if isfield(data,'aligned')
    aligned = data.aligned;
end

% collect spike times and waveforms into tt structure
nChans = getNbChannels(data.raw);
tt = struct('t',[],'w',{cell(1,nChans)},'aligned',aligned);
for i = 1:numel(data.chunks)
    tt.t = [tt.t; reshape(data.chunks(i).spikeTimes,[],1)];
    for j = 1:nChans
        w = data.chunks(i).spikeWaveforms(:,:,j);
        tt.w{j} = [tt.w{j}, w];
    end
end

% create spike height field
tt.h = zeros(size(tt.w{1},2),nChans);
for i = 1:nChans
    tt.h(:,i) = max(tt.w{i}) - min(tt.w{i});
end

data.tt = tt;

% save data
outDir = data.params.outDir;
if ~isempty(outDir)
    tet = data.params.tetrode;
    fileName = fullfile(getLocalPath(outDir),sprintf('Sc%u.Htt',tet));
    fprintf('Writing data to %s\n',fileName)
    ah_writeTT_HDF5(fileName,tt);
end
