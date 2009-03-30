function [x,sdt] = getCurrentSignal(sdt,operator)
% Get signal for current chunk of data.
%   [x,sdt] = getCurrentSignal(sdt,operator) applies the given operator to
%   the current chunk of data and caches the result (i.e. if it has been
%   calculated before, the cached result is simply returned).
%
% AE 2009-03-27

% no-op?
if isempty(operator)
    x = sdt.current.waveform;
    return
end

% apply operator or get cached result
opName = class(operator);
if ~isfield(sdt.cache,opName)
    sdt.cache.(opName) = apply(operator,sdt.current.waveform);
end
x = sdt.cache.(opName);
