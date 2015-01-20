function varargout = getParams(op,varargin)
% Get parameters.
%   val = getParams(op,'name') returns the specified parameter.
%
%   [val1,val2] = getParams(op,'param1','param2') returns multiple 
%   parameters.
%
%   parStruct = getParams(op) returns the entire parameter structure.
%
% AE 2009-03-27

% no parameter specified => return entire structure
if numel(varargin) == 0
    varargout{1} = op.params;
    return
end

% return specified parameters only
for i = 1:numel(varargin)
    varargout{i} = op.params.(varargin{i});
end
