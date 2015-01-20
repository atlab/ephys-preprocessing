function te = ThresholdEstimationEnergy(varargin)

% copy constructor
if nargin > 0 && isa(varargin{1},'ThresholdEstimationEnergy')
    te = varargin{1};
    return
end

te = class(struct,'ThresholdEstimationEnergy');
