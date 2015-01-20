function sdt = selectClean(sdt,varargin)
% Select non-overlaps spikes
%   sdt = selectClean(sdt) selects non-overlaps spikes and flags them.
%
% AE 2009-04-03

params.operator = SmoothedTEO;
params.refractory = 32;   % 1 ms
params = parseVarArgs(params,varargin{:});

% obtain spikes
spikes = getCurrentData(sdt,'spikeSamples');
[x,sdt] = getCurrentSignal(sdt,params.operator);
assert(isvector(x),'Selection of non-overlapping spikes needs vector signal!')

% find the ones within the refractory
ndx = find(diff(spikes) < params.refractory);
gaps = [0; find(diff(ndx) > 1)];
overlaps = false(size(spikes));
for i = 1:numel(gaps)-1
    group = [ndx(gaps(i)+1:gaps(i+1)); ndx(gaps(i+1))+1];
    [foo,m] = max(interp1q((1:numel(x))',x,spikes(group)));
    overlaps(group(setdiff(1:numel(group),m))) = true;
end
sdt = setChunkData(sdt,'spikeOverlaps',overlaps);
