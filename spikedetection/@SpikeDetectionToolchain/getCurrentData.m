function data = getCurrentData(sdt,name)
% Get temporary data for current chunk.
%   data = getCurrentData(sdt,name)
%
% AE 2009-03-27

data = sdt.current(end).(name);
