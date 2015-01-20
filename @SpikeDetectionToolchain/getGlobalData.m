function data = getGlobalData(sdt,name)
% Get global data
%   data = getGlobalData(sdt,name)
%
% AE 2009-03-27

data = sdt.global.(name);
