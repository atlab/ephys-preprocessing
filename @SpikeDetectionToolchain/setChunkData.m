function sdt = setChunkData(sdt,name,val)
% Set data for current chunk.
%   sdt = setChunkData(sdt,name,val) sets data for the current chunk which
%   should be stored. Unlike data set via setCurrentData, it will not be
%   deleted after the current chunk has been processed.
%
% AE 2009-03-27

sdt.chunks(end).(name) = val;
