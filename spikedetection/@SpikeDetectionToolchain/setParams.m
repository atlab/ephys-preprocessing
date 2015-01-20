function sdt = setParams(sdt,varargin)
% Set parameters.
%   sdt = setParams(sdt,'tstart',4711,'iend',2e6,...)
%
% AE 2009-02-24

sdt.params = parseVarArgs(sdt.params,varargin{:});
