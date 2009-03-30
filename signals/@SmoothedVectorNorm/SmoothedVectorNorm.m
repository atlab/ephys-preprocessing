function v = SmoothedVectorNorm(varargin)

% Copy constructor
if nargin == 1 && isa(varargin{1},'SmoothedVectorNorm')
    v = varargin{1};
    return
end

% Default/value constructor
params.p = 2;
params.win = getWin();
params = parseVarArgs(params,varargin{:},'assert');
v = class(struct,'SmoothedVectorNorm',Operator(params),VectorNorm('p',params.p));


% Special purpose smoothing window.
%   The idea is that spikes can have multiple (positive or negative) peaks
%   which we want to merge into a single event. I found this window to work
%   quite well.
function win = getWin()

win = gausswin(13,6);
win = win(5:end) + win(1:end-4);
win = conv(win,gausswin(7,2));
win = win / sum(win);
