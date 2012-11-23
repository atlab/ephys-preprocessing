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

params.segLen = 10;         % sec
params.noiseThresh = 10;    % greater than x times threshold is noise
params.refrac = 0.3;        % ms refractory for spikes
params = parseVarArgs(params, varargin{:});

[x, sdt] = getCurrentSignal(sdt);
[r, sdt] = getCurrentSignal(sdt, VectorNorm('p', 2));
thresh = getGlobalData(sdt, 'threshold');

% detect periods of noise
Fs = getSamplingRate(getReader(sdt));
t = getCurrentTime(sdt);
N = size(x, 1);
n = Fs * params.segLen;
m = ceil(N / n);
noise = false(N, 1);
artifacts = getGlobalData(sdt, 'noiseArtifacts');
for i = 1 : m
    if i < m
        ndx = (1 : n) + (i - 1) * m;
    else
        ndx = ((i - 1) * m + 1) : N;
    end
    isArtifact = any(median(abs(x(ndx, :)), 1) > thresh * 0.6745 * params.noiseThresh, 2);
    noise(ndx) = isArtifact;
    if isArtifact && (isempty(artifacts) || artifacts(end, 2) > 0) % start of artifact period
        artifacts(end + 1, 1) = t(ndx(1)); %#ok
    elseif ~isArtifact && ~isempty(artifacts) && artifacts(end, 2) == 0 % end of artifact period
        artifacts(end, 2) = t(ndx(1));
    end
end
sdt = setGlobalData(sdt, 'noiseArtifacts', artifacts);

% detect local maxima above threshold
above = any(bsxfun(@gt, x, thresh), 2);
dr = diff(r);
spikes = find(~noise(2 : end - 1) & above(2 : end - 1) & dr(1 : end - 1) > 0 & dr(2 : end) < 0) + 1;

% remove local maxima too close to each other (starting with largest
% working down to smallest spike)
[~, maxOrder] = sort(r(spikes), 'descend');
refrac = params.refrac / 1000 * Fs;
nMax = numel(spikes);
keep = true(nMax, 1);
for i = 1 : nMax
    current = maxOrder(i);
    if keep(current)
        k = current - 1;
        while k > 0 && keep(k) && spikes(current) - spikes(k) < refrac
            keep(k) = false;
            k = k - 1;
        end
        k = current + 1;
        while k <= nMax && keep(k) && spikes(k) - spikes(current) < refrac
            keep(k) = false;
            k = k + 1;
        end
    end
end
spikes = spikes(keep);
sdt = setCurrentData(sdt, 'spikeSamples', spikes);
