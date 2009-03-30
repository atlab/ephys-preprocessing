function b = isGlobalData(sdt,name)
% Returns true if a global data field of given name exists.
%   b = isGlobalData(sdt,name)
%
% AE 2009-03-27

b = isfield(sdt.global,name);
