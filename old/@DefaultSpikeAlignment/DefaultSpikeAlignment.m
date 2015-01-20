function sa = DefaultSpikeAlignment(varargin)

% copy constructor
if nargin > 0 && isa(varargin{1},'DefaultSpikeAlignment')
    sa = varargin{1};
    return
end

sa = class(struct,'DefaultSpikeAlignment');
