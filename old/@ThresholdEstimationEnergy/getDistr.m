function par = getDistr(te,wave,win)
% Estimate standard deviation of noise using cap fitting of a normal
% distribution.
%
% AE 2009-03-08

% some settings
n = 200;
% par = [mu, sigma]
f = @(par,x) 1 / (sqrt(2*pi) * par(2)) * exp(-1/2 *  (x - par(1)).^2 / par(2)^2);
opt = optimset('MaxFunEvals',10^25,'TolFun',1e-20,'Display', 'off');

% convert to energy
wave = sqrt(sum(wave.^2,2));

% lowpass filter
winSize = (length(win) - 1) / 2;
wave = conv(wave,win);
wave = wave(winSize+1:end-winSize);

% compute distribution
mx = max(wave);
binWidth = mx / n;
c = linspace(0,mx,n);
h = hist(wave,c);
h = h / sum(h);

med = median(wave);
ndx = find(h > max(h)/2);

% fit normal distribution
par = lsqcurvefit(f,[med std(wave)],c(ndx),h(ndx)/binWidth,[],[],opt);
