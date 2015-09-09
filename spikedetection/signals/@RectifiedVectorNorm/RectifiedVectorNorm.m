function v = RectifiedVectorNorm(varargin)

% Copy constructor
if nargin == 1 && isa(varargin{1},'RectifiedVectorNorm')
    v = varargin{1};
    return
end

% Default/value constructor
params.p = 2;
params = parseVarArgs(params,varargin{:},'assert');
v = class(struct,'RectifiedVectorNorm',Operator(params));
