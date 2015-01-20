function par = capfit(x,range)
% Estimate parameters of normal distribution by cap fitting.
%   par = capfit(x) will fit a normal distribution using only the part of
%   the histogram which is above half maximum. par is a 1-by-3 vector
%   containing the prior for the normal mixture component, its mean, and
%   its standard deviation.
%
%   par = capfit(x,range) will only consider data within the specified
%   range.
%
% AE 2009-03-27

% some settings
n = 200;
% par = [prior, mu, sigma]
f = @(par,x) par(1) / (sqrt(2*pi) * par(3)) * exp(-1/2 * (x - par(2)).^2 / par(3)^2);
opt = optimset('MaxFunEvals',10^25,'TolFun',1e-20,'Display','off');

% compute distribution
if nargin < 2
    mx = max(x);
    mn = min(min(x),0);
    binWidth = (mx - mn) / n;
    c = linspace(mn,mx,n);
else
    c = linspace(range(1),range(2),n);
end
h = histc(x,c);
h = h / sum(h);

% use the portion of the histogram which is above half maximum
ndx = find(h > max(h)/2);

% fit normal distribution
parMin = [0 -Inf 0];
parMax = [1 Inf Inf];
par0 = [1 nanmedian(x) nanstd(x)];
par = lsqcurvefit(f,par0,c(ndx)',h(ndx)/binWidth,parMin,parMax,opt);
