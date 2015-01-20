function sd = DetectionPeakAboveThreshold(varargin)

% copy constructor
if nargin > 0 && isa(varargin{1},'DetectionPeakAboveThreshold')
    sd = varargin{1};
    return
end

sd = class(struct,'DetectionPeakAboveThreshold');
