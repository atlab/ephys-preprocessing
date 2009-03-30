function sd = SaveData(varargin)

% copy constructor
if nargin > 0 && isa(varargin{1},'SaveData')
    sd = varargin{1};
    return
end

sd = class(struct,'SaveData');
