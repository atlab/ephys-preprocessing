function sigma = getSigma(te,wave)
% Estimate standard deviation of noise using cap fitting of a normal
% distribution.
%
% AE 2009-02-26

% some settings
n = 99;
ndx = (n+1)/2 + (-5:5);
f = @(sigma,x) 1 / (sqrt(2*pi) * sigma) * exp(-1/2 *  x.^2 / sigma^2);
opt = optimset('MaxFunEvals',10^25,'TolFun',1e-20,'Display', 'off');

% make zero meam
wave = wave - mean(wave,1);

% compute distribution
maxAbs = max(abs(wave));
binWidth = 2 * maxAbs / (n-1);
c = linspace(-maxAbs,maxAbs,n);
h = hist(wave,c);
h = h / sum(h);

% fit normal distribution
sigma = lsqcurvefit(f,std(wave),c(ndx),h(ndx)/binWidth,[],[],opt);
