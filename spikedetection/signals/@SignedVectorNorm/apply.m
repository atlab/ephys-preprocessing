function y = apply(v,x)

% apply vector norm
p = getParams(v,'p');
switch p
    case 1
        y = sum(abs(x),2);
    case 2
        y = sqrt(sum(x.^2,2));
    case Inf
        y = max(abs(x),[],2);
    otherwise
        y = sum(abs(x).^p,2).^(1/p);
end
y = y .* sign(sum(x,2));
