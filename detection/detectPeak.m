function sdt = detectPeak(sdt,varargin)
% Detect spikes as local maxima above threshold.
%   sdt = detectPeak(sdt) detects spikes by finding all local maxima above
%   a certain threshold.
%
% AE 2009-03-27

params.operator = SmoothedTEO;
params = parseVarArgs(params,varargin{:});

[x,sdt] = getCurrentSignal(sdt,params.operator);
dx = diff(x);
thresh = getGlobalData(sdt,'threshold');

% Detect spikes
spikes = find(x(2:end-1) > thresh & dx(1:end-1) > 0 & dx(2:end) <= 0) + 1;
sdt = setCurrentData(sdt,'spikeSamples',spikes);
