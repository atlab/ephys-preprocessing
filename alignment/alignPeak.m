function sdt = alignPeak(sdt,varargin)
% Align spikes to their peak.
%   sdt = alignPeak(sdt) aligns all spikes to their peak. The waveform is
%   upsampled to get a more accurate peak location.
%
% AE 2009-03-27

params.operator = SmoothedTEO;
params.searchWin = -2:2;
params.upsample = 5;
params.filterLength = 2;    % filter length = 2*length+1
params = parseVarArgs(params,varargin{:});

spikes = getCurrentData(sdt,'spikeSamples');
[x,sdt] = getCurrentSignal(sdt,params.operator);

% if window is large, find approximate peak first
win = params.searchWin;
if numel(win) > 10
    [foo,peakNdx] = max(x(bsxfun(@plus,spikes,win)),[],2);
    spikes = spikes + peakNdx + params.searchWin(1) - 1;
end

% create window for upsampling
up = params.upsample;
len = params.filterLength;
win = win(1)-2*len:win(end)+2*len;

% need to trash spikes too close to segment edges
ndx = spikes+win(1) > 0 & spikes+win(end) <= size(x,1);
spikes = spikes(ndx);
% TODO: keep track of what we throw out...

% upsampled peak
if ~isempty(spikes)
    x = x(bsxfun(@plus,spikes,win));
    x = resample(x',up,1,len);
    [foo,peakNdx] = max(x,[],1);
    spikes = spikes - 2*len + (peakNdx'-1)/up;
end
sdt = setCurrentData(sdt,'spikeSamples',spikes);

% put flag that we aligned the spikes
sdt = setGlobalData(sdt,'aligned',true);
