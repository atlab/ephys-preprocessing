function wave = getCurrentTime(sdt)
% Returns sample times for current chunk of data.
%   wave = getCurrentTime(sdt)
%
% AE 2009-03-27

wave = sdt.current.time;
