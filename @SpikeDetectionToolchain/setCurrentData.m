function sdt = setCurrentData(sdt,name,val)
% Set temporary data for current chunk.
%   sdt = setCurrentData(sdt,name,val) sets temporary data. This data will
%   be deleted after the current chunk has been processed.
%
% AE 2009-03-27

sdt.current(end).(name) = val;
