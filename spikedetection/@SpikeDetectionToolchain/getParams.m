function varargout = getParams(sdt,varargin)
% Get parameters.
%   val = getParams(sdt,'name') returns the specified parameter.
%
%   [val1,val2] = getParams(sdt,'param1','param2') returns multiple 
%   parameters.
%
%   parStruct = getParams(sdt) returns the entire parameter structure.
%
% AE 2009-02-24

% no parameter specified => return entire structure
if numel(varargin) == 0
    varargout{1} = sdt.params;
    return
end

% return specified parameters only
for i = 1:numel(varargin)
    varargout{i} = sdt.params.(varargin{i});
end
