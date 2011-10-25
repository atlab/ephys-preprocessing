function v = MaxChannel(varargin)

% Copy constructor
if nargin == 1 && isa(varargin{1}, 'MaxChannel')
    v = varargin{1};
    return
end

% Default/value constructor
v = class(struct, 'MaxChannel', Operator);
