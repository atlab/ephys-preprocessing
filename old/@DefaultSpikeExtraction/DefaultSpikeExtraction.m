function se = DefaultSpikeExtraction(varargin)

% copy constructor
if nargin > 0 && isa(varargin{1},'DefaultSpikeExtraction')
    se = varargin{1};
    return
end

se = class(struct,'DefaultSpikeExtraction');
