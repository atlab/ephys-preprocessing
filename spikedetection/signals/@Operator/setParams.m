function op = setParams(op,varargin)
% Set parameters.
%   op = setParams(op,'tstart',4711,'iend',2e6,...)
%
% AE 2009-03-27

op.params = parseVarArgs(op.params,varargin{:});
