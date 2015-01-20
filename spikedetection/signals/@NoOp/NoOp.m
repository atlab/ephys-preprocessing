function w = NoOp(varargin)

% Copy constructor
if nargin == 1 && isa(varargin{1},'NoOp')
    w = varargin{1};
    return
end

% Default/value constructor
w = class(struct,'NoOp',Operator);
