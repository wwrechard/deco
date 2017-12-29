function coef = LASSO(X, Y, gamma, intercept, refine, maxit)
% A convenient wrapper over glmnet package for 'lasso'.

if nargin == 2
    gamma = 1;
    intercept = false;
    refine = false;
    maxit = 100000;
elseif nargin == 3
    intercept = false;
    refine = false;
    maxit = 100000;
elseif nargin == 4
    refine = false;
    maxit = 100000;
elseif nargin == 5
    maxit = 100000;
end
options = glmnetSet;
options.maxit = maxit;

[n, p] = size(X);
m1 = glmnet(X, Y, 'gaussian', options);
nrho = length(m1.lambda);
RSS = sum(([ones(n,1) X]*glmnetCoef(m1) - repmat(Y, 1, nrho)).^2);
EBIC = log(RSS/n) + m1.df'/n*(log(n) + 2*gamma*log(p));
%EBIC = m1.nulldev * (1 - m1.dev) + m1.df*(log(n) + 2*gamma*log(p));
[~, idxmin] = min(EBIC);
if refine
    if intercept
        beta = glmnetCoef(m1);
        beta = beta(:, idxmin);
        coef = refining([ones(n,1) X], Y, beta);
    else
        beta = m1.beta(:, idxmin);
        coef = refining(X, Y, beta);
    end
else
    if intercept
        beta = glmnetCoef(m1);
        coef = beta(:,idxmin);
    else
        coef = m1.beta(:,idxmin);
    end
end
end