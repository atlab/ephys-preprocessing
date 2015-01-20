function sdt = alignCOM(sdt,varargin)
% Align spikes to their center of mass.
%   sdt = alignCOM(sdt) aligns all spikes to their center of mass (COM).
%   The waveform is upsampled to get a more accurate location.
%
% AE 2009-03-27

params.operator = SmoothedTEO;
params.searchWin = -10:10;
params.peakFrac = 0.5;
params.subtractMeanNoise = false;
params.upsample = 5;
params.filterLength = 2;    % filter length = 2*length+1
params = parseVarArgs(params,varargin{:});

% put flag that we aligned the spikes
sdt = setGlobalData(sdt,'aligned',true);

% obtain spikes to align
spikes = getCurrentData(sdt,'spikeSamples');
[x,sdt] = getCurrentSignal(sdt,params.operator);
assert(isvector(x),'Center of mass alignement needs vector signal!')

% % if window is large, find approximate peak first
% win = params.searchWin;
% if numel(win) > 10
%     [foo,peakNdx] = max(x(bsxfun(@plus,spikes,win)),[],2);
%     spikes = spikes + peakNdx + params.searchWin(1) - 1;
% end

% create window for upsampling
win = params.searchWin;
up = params.upsample;
len = params.filterLength;
win = win(1)-2*len:win(end)+2*len;

% need to trash spikes too close to segment edges
ndx = spikes+win(1) > 0 & spikes+win(end) <= size(x,1);
spikes = spikes(ndx);
% TODO: keep track of what we throw out...

% no spikes left?
if isempty(spikes)
    sdt = setCurrentData(sdt,'spikeSamples',spikes);
    return
end

% upsample
x = x(bsxfun(@plus,spikes',win'));
if params.subtractMeanNoise
    noiseMean = getGlobalData(sdt,'noiseMean');
    x = x - noiseMean;
end
x = resample(x,up,1,len);

% determine closest peak location (approximate)
%   weigh amplitudes by distance to detected event to favor solution close
%   to the detected location
[nSamples,nSpikes] = size(x);
[foo,peakNdx] = max(bsxfun(@times,triang(nSamples),x),[],1);

% align to center of mass
dx = diff(x);
frac = params.peakFrac;
com = zeros(nSpikes,1);
for i = 1:nSpikes
    
    % determine exact peak location (closest local maximum)
    p = peakNdx(i);
    if ~(dx(p-1,i) > 0 && dx(p,i) <= 0)
        m1 = find(dx(1:p-2,i) > 0 & dx(2:p-1,i) <= 0,1,'last');
        if isempty(m1), m1 = p; end
        m2 = find(dx(p:end-1,i) > 0 & dx(p+1:end,i) <= 0,1,'first');
        if isempty(m2), m2 = nSamples-1; end
        if p - m1 < m2
            p = m1 + 1;
        else
            p = p + m2;
        end
    end
    ampl = x(p,i);
    
    % determine range where signal above threshold
    b1 = find(x(1:p-1,i) < ampl * frac,1,'last');
    if isempty(b1), b1 = 1; end
    b2 = find(dx(1:p-1,i) < 0,1,'last');
    if isempty(b2), b2 = 1; end
    e1 = find(x(p+1:end,i) < ampl * frac,1,'first') + p;
    if isempty(e1), e1 = nSamples; end
    e2 = find(dx(p:end,i) > 0,1,'first') + p;
    if isempty(e2), e2 = nSamples; end
    ndx = max(b1,b2):min(e1,e2);
    
    % compute center of mass
    com(i) = ndx * x(ndx,i) / sum(x(ndx,i));
end

spikes = spikes + win(1) + (com-1)/up;

sdt = setCurrentData(sdt,'spikeSamples',spikes);

