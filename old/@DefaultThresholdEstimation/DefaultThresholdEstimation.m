function te = DefaultThresholdEstimation(varargin)

% copy constructor
if nargin > 0 && isa(varargin{1},'DefaultThresholdEstimation')
    te = varargin{1};
    return
end

te = class(struct,'DefaultThresholdEstimation');
