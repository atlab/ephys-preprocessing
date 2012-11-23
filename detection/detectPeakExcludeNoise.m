function sdt = detectPeakExcludeNoise(sdt, varargin)
% Detect spikes as local maxima above threshold.
%   sdt = detectPeak(sdt) detects spikes by finding all local maxima above
%   a certain threshold. Between two adjacent maxima the trace has to go
%   drop below threshold
%
%   This function also automatically excludes segments in the data that
%   have excessively large variance (which happens when the preamps were
%   turned after starting the recording or off before stopping it).
%
% AE 2012-11-09

params.segLen = 5;          % sec
params.noiseThresh = 10;    % greater than x times threshold is noise
params = parseVarArgs(params, varargin{:});

[x, sdt] = getCurrentSignal(sdt);
[y, sdt] = getCurrentSignal(sdt, VectorNorm('p', 2));
thresh = getGlobalData(sdt, 'threshold');

% detect periods of noise
Fs = getSamplingRate(getReader(sdt));
N = size(x, 1);
n = Fs * params.segLen;
m = ceil(N / n);
spikes = false(N, 1);
for i = 1 : m
    if i < m
        ndx = (1 : n) + (i - 1) * m;
    else
        ndx = ((i - 1) * m + 1) : N;
    end
    spikes(ndx) = all(median(abs(x(ndx, :)), 1) ...
                        < thresh * 0.6745 * params.noiseThresh, 2);
end

% detect local maxima
mx = max(x, [], 2);
r = sum(x .* x, 2);
dr = diff(r);
maxIndices = find(mx(2 : end - 1) > thresh & dr(1 : end - 1) > 0 & dr(2 : end) < 0) + 1;

% remove local maxima too close to each other
[maxVals, maxOrder] = sort(r(maxIndices), 'descend');
keep = true(size(maxIndices));
for i = 1 : numel(maxIndices)
    
end

% 
% above = any(bsxfun(@gt, x, thresh), 2);
% i = 1;
% while i < N
%     while i <= N && (~spikes(i) || ~above(i))   % go to next spike
%         spikes(i) = false;
%         i = i + 1;
%     end
%     start = i;
%     while i <= N && spikes(i) && above(i)       % go to end of spike
%         i = i + 1;
%     end
%     [~, ndx] = max(y(start : i - 1));
%     spikes(start : i) = false;
%     spikes(start + ndx - 1) = true;
% end
% spikes = find(spikes);



sdt = setCurrentData(sdt, 'spikeSamples', spikes);
