function w = AvgWaveform(varargin)

% Copy constructor
if nargin == 1 && isa(varargin{1},'AvgWaveform')
    w = varargin{1};
    return
end

% Default/value constructor
w = class(struct,'AvgWaveform',Operator);
