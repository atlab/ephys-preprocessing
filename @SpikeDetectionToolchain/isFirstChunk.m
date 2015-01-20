function isFirst = isFirstChunk(sdt)
% Returns true if it's processing the first chunk
%   isFirst = isFirstChunk(sdt)
%
% AE 2009-04-03

isFirst = length(sdt.chunks) == 1;
