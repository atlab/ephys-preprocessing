function data = getChunkData(sdt,name)
% Get data for current chunk.
%   data = getChunkData(sdt,name)
%
% AE 2009-03-27

data = sdt.chunks(end).(name);
