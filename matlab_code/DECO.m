function output = DECO(X, Y, m, method, gamma, intercept, refine, deco)
% Function for decorrelated regression with lasso, scad and mcp.
% Args:
%   X: Input predictors. Rows are samples and columns are features.
%   Y: Response.
%   m: The number of partitions. Default to 5.
%   method: 'lasso', 'scad' or 'mcp'. Default to 'lasso'
%   gamma: The parameter in the extended BIC. Default to 0.5.
%   intercept: Whether to include an intercept. Default to false.
%   refine: Whether to apply a refine step after fitting decorrelated
%           fitting. Default to true.
%   deco: Whether to apply the decorrelation step or not. Default to true.
%
% Returns:
%   An object with .model containing the non-zero index and .coef
%   containing the coefficients.
%
% Example:
%   [X, Y, beta] = data_gen(100, 1000, 5, 'ind', 0.95);
%   output = DECO(X, Y, 5, 'lasso');

% ==== process input params ====
if nargin == 2
    m = 5;
    method = 'lasso';
    gamma = 0.5;
    intercept = false;
    refine = true;
    deco = true;
elseif nargin == 3
    method = 'lasso';
    gamma = 0.5;
    intercept = false;
    refine = true;
    deco = true;
elseif nargin == 4
    gamma = 0.5;
    intercept = false;
    refine = true;
    deco = true;
elseif nargin == 5
    intercept = false;
    refine = true;
    deco = true;
elseif nargin == 6
    refine = true;
    deco = true;
elseif nargin == 7
    deco = true;
end
[n, p] = size(X);

beta = zeros(p, 1);

%=========== standardize =============
y = Y - mean(Y);
x = X - repmat(mean(X), n, 1);

%======== partition =========
sizeOfSet = floor(p/m);
sets = cell(1, m);
x_subset = cell(1, m);
predictors = randperm(p);
for i = 1 : (m - 1)
    sets{i} = predictors((sizeOfSet * (i - 1) + 1) : sizeOfSet * i);
    x_subset{i} = x(:, sets{i});
end
sets{m} = predictors((sizeOfSet * (m - 1) + 1) : p);
x_subset{m} = x(:, sets{m});

%======== decorrelation ==============
deco_matrix = zeros(n);
F = eye(n);
if deco
    parfor i = 1 : m
        deco_matrix = deco_matrix + x_subset{i} * x_subset{i}';
    end
    [U, D] = eig(deco_matrix);
    if refine
        robustTerm = 1;
    else
        robustTerm = 10;
    end
    F = sqrt(p) * U * diag(1./sqrt((diag(D) + robustTerm))) * U';
    y = F * y;
end

%========== estimation ===========
parfor i = 1 : m
    if strcmp(method, 'lasso')
        beta_temp = LASSO(F * x_subset{i}, y, gamma, false, refine);
    elseif strcmp(method, 'scad')
        beta_temp = SCAD(F * x_subset{i}, y, gamma, false, refine);
    elseif strcmp(method, 'mcp')
        beta_temp = MCP(F * x_subset{i}, y, gamma, false, refine);
    end
    beta_i = zeros(p, 1);
    beta_i(sets{i}) = beta_temp;
    beta = beta + beta_i;
end

%=========== refine (optional) ===========
if refine
    M = find(abs(beta) > 1e-7);
    if length(M) > n
        if strcmp(method, 'lasso')
            beta = LASSO(x(:, M), y, gamma);
        elseif strcmp(method, 'scad')
            beta = SCAD(x(:, M), y, gamma);
        elseif strcmp(method, 'mcp')
            beta = MCP(x(:, M), y, gamma);
        end
        M = M(abs(beta) > 1e-7);
    end
    Xnew = [ones(n, 1), X(:, M)];
    beta = zeros(p, 1);
    r = TuneRidge(Xnew, Y, 10, n, 20, length(M)+1, true);
    coef = (Xnew' * Xnew + r * n * eye(length(M)+1))\(Xnew' * Y);
    inte = coef(1);
    beta(M) = coef(2:end);
else
    inte = mean(Y - X * beta);
end

%=========== final output =============
output.model = find(abs(beta) > 1e-7);
if intercept
    output.coef = [inte; beta];
else
    output.coef = beta;
end
end