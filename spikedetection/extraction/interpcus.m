function [v] = clus_interp_custom(X,Y, XX)
% interpolate each row of Y, with original coordinates stored in X, by cubic spline
% interplation and evaluate at the positions stored in XX
% For each row you have to specify the positions where to sample from the
% interpolant.
% Why is this function necessary? Matlab's functions will evaluate all
% interpolated curves at the same abscisses. But we want to align every
% spike to its very own peak.
% X   -   vector with the D abscisses where the values in Y were original
%         sampled at
% Y   -   D x n matrix
% XX  -   n x m matrix with the positions where you want to sample
%         from the interpolant
%
% AH 02-06-2006
% refer to Matlab's ppval function, which is a bit easier to understand

pp = spline(X,Y');               % Calculate piecewise polynomial
[b,c,l,k,dd]=unmkpp(pp);         % Extract pp information

nRows = size(XX,1);
% for each data point, compute its breakpoint interval
[ignored,index] = sort([repmat(b(1:l),nRows,1) XX], 2);
clear ignored
helperArr = repmat( 1:(l+size(XX,2)), nRows, 1)';
%index = reshape(helperArr(index' > l), [], nRows)' - repmat(1:size(XX,2), nRows, 1);
index = bsxfun(@minus, reshape(helperArr(index' > l), [], nRows)', repmat(1:size(XX,2), nRows, 1));
index(index<1) = 1;

% now go to local coordinates ...
XX = reshape(XX, 1, []) - b( reshape(index, 1,[]));
%index = (index - 1) * nRows + repmat((1:nRows)', 1, size(index,2));
index = bsxfun(@plus, (index - 1) * nRows, (1:nRows)');
index = index(:);

% ... and apply nested multiplication:
v = c(index,1);
for i=2:k
   v = XX(:).*v + c(index,i);
end
v = reshape(v,nRows,[])';
