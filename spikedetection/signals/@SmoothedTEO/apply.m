function x = apply(teo,x)

% apply Teager Energy Operator
n = size(x,2);
x = mean(x.^2 - [x(2:end,:); zeros(1,n)] .* [zeros(1,n); x(1:end-1,:)],2);

% sqrt transform?
if getParams(teo,'sqrt')
    x(x < 0) = 0;
    x = sqrt(x);
end

% smooth
k = getParams(teo,'smooth');
win = gausswin(2*k+1);
win = win / sum(win);
x = conv(x,win);
x = x(k+1:end-k);
