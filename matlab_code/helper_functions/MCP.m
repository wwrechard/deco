function coef = MCP(X, Y, gamma, intercept, refine)
% A convenient wrapper over sparseReg package for 'mcp'.

if nargin == 2
    gamma = 1;
    intercept = false;
    refine = false;
elseif nargin == 3
    intercept = false;
    refine = false;
elseif nargin == 4
    refine = false;
end
[n, p] = size(X);
penalty = 'mcp';
penparam = 1;
if intercept
    penidx = [false;true(p,1)];
    X = [ones(n,1) X];
else
    penidx = true(p, 1);
end
maxpreds = floor(sqrt(p)/2);
[rho_path, beta_path] = lsq_sparsepath(X, Y, 'penalty',...
    penalty, 'penidx', penidx, 'penparam', penparam, 'maxpreds', maxpreds);
nrho = length(rho_path);
RSS = sum((X*beta_path - repmat(Y, 1, nrho)).^2);
df = sum(beta_path~=0);
EBIC = log(RSS/n) + df/n*(log(n) + 2*gamma*log(p));
[~, idxmin] = min(EBIC);
beta = beta_path(:,idxmin);
if refine
    coef = refining(X, Y, beta);
else
    coef = beta;
end
end