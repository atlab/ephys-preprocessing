function data = run(sa,data)
% Align spikes
% AE 2009-02-26

spikes = data.chunks(end).spikeSamples;
w = data.current.energy;

bndx = -(0:20);
andx = 0:20;

% need to trash spikes too close to the edges
spikes(spikes <= -bndx(end) | spikes > size(w,1)-andx(end)) = [];

for i = 1:numel(spikes)
    
    % process segment before peak
    wb = w(spikes(i) + bndx);
    
    % segments above threshold
    n = find(wb < data.threshold,1,'first');
    if isempty(n), n = length(bndx); end
    wb = wb(1:n);
    
    % last local minimum before current peak
    dw = diff(wb);
    mini = find(dw(1:end-1) <= 0 & dw(2:end) > 0,1,'first');
    if ~isempty(mini)
        wb = wb(1:mini+1);
    end
    
    % process segment after peak
    wa = w(spikes(i) + andx);
    
    % segments above threshold
    n = find(wa < data.threshold,1,'first');
    if isempty(n), n = length(andx); end
    wa = wa(1:n);
    
    % last local minimum before current peak
    dw = diff(wa);
    mini = find(dw(1:end-1) <= 0 & dw(2:end) > 0,1,'first');
    if ~isempty(mini)
        wa = wa(1:mini+1);
    end
    
    ww = [wb; wa(2:end)];
    com = [bndx(1:length(wb)), andx(2:length(wa))] * ww / sum(ww);
    spikes(i) = spikes(i) + com;
    
end

data.chunks(end).spikeSamples = spikes;
data.aligned = true;
