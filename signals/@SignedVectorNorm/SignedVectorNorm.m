function v = SignedVectorNorm(varargin)

% Copy constructor
if nargin == 1 && isa(varargin{1},'SignedVectorNorm')
    v = varargin{1};
    return
end

% Default/value constructor
params.p = 2;
params = parseVarArgs(params,varargin{:},'assert');
v = class(struct,'SignedVectorNorm',Operator(params));
