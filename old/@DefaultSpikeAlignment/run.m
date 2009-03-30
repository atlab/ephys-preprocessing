function data = run(sa,data)
% Align spikes
% AE 2009-02-26

spikes = data.chunks(end).spikeSamples;
ctPoint = data.params.ctPoint;
w = data.chunks(end).spikeWaveforms;
w = sqrt(sum(w.^2,3));    % compute c.o.m. on distance to origin
dw = diff(w(ctPoint:end,:));

comWin = data.params.comWin;
for i = 1:size(w,2)
    
    % find next peak
    peak = find(dw(:,i) < 0,1);
    
    % determine center of mass around peak
    ndx = ctPoint + peak + comWin - 1;
    com = comWin * w(ndx,i) / sum(w(ndx,i));
    spikes(i) = spikes(i) + peak + com - 1;
end

data.chunks(end).spikeSamples = spikes;
