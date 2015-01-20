function x = apply(v,x)

% apply vector norm
p = getParams(v,'p');
switch p
    case 1
        x = sum(abs(x),2);
    case 2
        x = sqrt(sum(x.^2,2));
    case Inf
        x = max(abs(x),[],2);
    otherwise
        x = sum(abs(x).^p,2).^(1/p);
end
