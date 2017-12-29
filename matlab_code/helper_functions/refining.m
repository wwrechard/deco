function coef = refining(X, Y, beta)
[n, p] = size(X);
M = find(beta~=0);
Xnew = X(:, M);
coef = zeros(size(beta));
r = TuneRidge(Xnew, Y, 10, n, 20, length(M), true);
coef(M) = (Xnew' * Xnew + r * n * eye(length(M)))\(Xnew' * Y);
end