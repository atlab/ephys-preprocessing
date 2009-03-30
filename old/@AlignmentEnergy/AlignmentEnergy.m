function sa = AlignmentEnergy(varargin)

% copy constructor
if nargin > 0 && isa(varargin{1},'AlignmentEnergy')
    sa = varargin{1};
    return
end

% define parameters (no parameters)
params = struct;

% construct class object
sa = class(struct,'AlignmentEnergy',DetectionStep(params));
