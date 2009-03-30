function sd = DetectionEnergy(varargin)

% copy constructor
if nargin > 0 && isa(varargin{1},'DetectionEnergy')
    sd = varargin{1};
    return
end

% define parameters (no parameters)
params.smooth = 5;    % gausswin(2*n+1)
params = parseVarArgs(params,varargin{:},'assert');

% construct class object
sd = class(struct,'DetectionEnergy',DetectionStep(params));
