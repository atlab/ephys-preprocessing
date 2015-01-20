function x = apply(v,x)

% apply vector norm
x = apply(v.VectorNorm,x);

% smoothing
win = getParams(teo,'win');
k = (length(win) - 1) / 2;
x = conv(x,win);
x = x(k+1:end-k);
