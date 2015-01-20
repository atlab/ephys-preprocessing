function op = Operator(varargin)
% Base class for all operators.
% AE 2009-03-27

% Copy constructor
if nargin == 1 && isa(varargin{1},'Operator')
    op = varargin{1};
    return
end

% Default/value constructor
if nargin == 1 && isstruct(varargin{1})
    params = varargin{1};
else
    params = parseVarArgs(struct,varargin{:});
end

op.params = params;
op = class(op,'Operator');
