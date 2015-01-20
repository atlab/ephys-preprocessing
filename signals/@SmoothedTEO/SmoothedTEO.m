function teo = SmoothedTEO(varargin)

% Copy constructor
if nargin == 1 && isa(varargin{1},'SmoothedTEO')
    teo = varargin{1};
    return
end

% Default/value constructor
params.smooth = 5;
params.sqrt = true;
params = parseVarArgs(params,varargin{:},'assert');
teo = class(struct,'SmoothedTEO',Operator(params));
