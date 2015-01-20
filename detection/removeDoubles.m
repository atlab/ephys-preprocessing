function sdt = removeDoubles(sdt, varargin)
% Remove double-triggered spikes.
%   sdt = removeDoubles(sdt) removes all double-triggered spikes by
%   implementing a refractory period, within which no two spikes can occur.
%   If multiple peaks are detected within the refractory period only the
%   largest is retained.
%
% AE 2012-11-23

params.refrac = 0.3;        % ms refractory for spikes
params = parseVarArgs(params, varargin{:});

% get spikes
[r, sdt] = getCurrentSignal(sdt, VectorNorm('p', 2));
spikes = getCurrentData(sdt, 'spikeSamples');

% remove local maxima too close to each other (starting with largest
% working down to smallest spike)
[~, maxOrder] = sort(interp1(r, spikes, 'pchip'), 'descend');
Fs = getSamplingRate(getReader(sdt));
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
