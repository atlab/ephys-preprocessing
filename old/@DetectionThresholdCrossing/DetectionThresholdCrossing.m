function sd = DetectionThresholdCrossing(varargin)

% copy constructor
if nargin > 0 && isa(varargin{1},'DetectionThresholdCrossing')
    sd = varargin{1};
    return
end

sd = class(struct,'DetectionThresholdCrossing');
