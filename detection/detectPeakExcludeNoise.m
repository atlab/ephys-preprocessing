function sdt = detectPeakExcludeNoise(sdt, varargin)
% Detect spikes as local maxima above threshold.
%   sdt = detectPeak(sdt) detects spikes by finding all local maxima above
%   a certain threshold.
%
%   This function also automatically excludes segments in the data that
%   have excessively large variance (which happens when the preamps were
%   turned after starting the recording or off before stopping it).
%
% AE 2012-11-09

params.segLen = 1000;       % samples (~30 ms)
params.minGap = 160;        % segments (5 sec)
params.noiseThresh = 30;    % muV robust SD within segment
params = parseVarArgs(params, varargin{:});

[x, sdt] = getCurrentSignal(sdt);
[r, sdt] = getCurrentSignal(sdt, VectorNorm('p', 2));
thresh = getGlobalData(sdt, 'threshold');

% crop end of recording to multiples of params.segLen samples
reader = getReader(sdt);
[n, k] = size(x);
m = fix(n / params.segLen);
if getCurrentChunk(sdt) == length(reader)
    n = params.segLen * m;
    x = x(1 : n, :);
    r = r(1 : n);
else
    assert(~mod(n, params.segLen), 'segLen must be integer fraction of chunk size!')
end

% detect noise bursts
xr = reshape(x, [params.segLen, m ,k]);
noiseBursts = find(any(median(abs(xr), 1) / 0.6745 > params.noiseThresh, 3));

% close gaps shorter than params.minGaps
t = getCurrentTime(sdt);
Fs = getSamplingRate(reader);
dt = params.minGap * params.segLen / Fs * 1000;
artifacts = getGlobalData(sdt, 'noiseArtifacts');
for i = 1 : numel(noiseBursts)
    index = (noiseBursts(i) - 1) * params.segLen;
    if isempty(artifacts) || artifacts(end, 2) > 0
        % start of artifact period
        artifacts(end + 1, 1) = t(index + 1) - dt / 2; %#ok
    elseif ~isempty(artifacts) && artifacts(end, 2) == 0
        if i == numel(noiseBursts) && noiseBursts(i) < m - params.minGap / 2 ...
                || i < numel(noiseBursts) && diff(noiseBursts(i : i + 1)) > params.minGap
            % end of artifact period
            artifacts(end, 2) = t(index + params.segLen) + dt / 2;
        end
    end
end
sdt = setGlobalData(sdt, 'noiseArtifacts', artifacts);

% detect local maxima above threshold
above = any(bsxfun(@gt, x, thresh), 2);
dr = diff(r);
spikes = find(above(2 : end - 1) & dr(1 : end - 1) > 0 & dr(2 : end) < 0) + 1;

sdt = setCurrentData(sdt, 'spikeSamples', spikes);
