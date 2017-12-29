function [FN, FP, Er] = experiment(n, p, model, method, repeat, heavytailed)
% This is a integrated function for testing the DECO method, including data
% generation, fitting and performance evaluation (False positive and
% negative, timing, etc). This function is a wrapper over DECO.m,
% data_gen.m and data_gen_heavytail.m. The function compare five different
% form of a single method. For example if method == 'lasso', the results
% will contain five rows with results of:
%   1. Lasso with full data
%   2. Refined lasso with full data
%   3. Naively partitioned parallel lasso.
%   4. Refined DECO + lasso.
%   5. DECO + lasso.
%
% Args:
%   n: Sample size.
%   p: Number of variables.
%   model: The model type. Possible choise: 'ind', 'corr', 'group',
%          'factor', 'l1-ball'. Details please see 'help data_gen'.
%   method: The regularized method to be combined with DECO. Options are
%          'lasso', 'scad' and 'mcp'.
%   repeat: The number of synthetic dataset to be generated and run.
%   heavytailed: Whether the data should have a heavytailed noise.
%
% Returns:
%   The evaluation results. FN: False negatives. FP: False positives. Er:
%   MSE. Each with five rows coressponding to the five different forms and
%   each column is one synthatic dataset.
%
% Example:
%   [FN, FP, Er] = experiment(500, 10000, 'corr', 'lasso', 10, false);

s = 5;
gamma = 0.5;
m = 100;
num = 5;  % num of different forms.

FN = zeros(num, repeat);
FP = zeros(num, repeat);
Er = zeros(num, repeat);

for i = 1 : repeat
    if heavytailed
        [X, Y, beta] = data_gen_heavytail(n, p, s, model);
    else
        [X, Y, beta] = data_gen(n, p, s, model);
    end
    support = find(beta~=0);
    if strcmp(method, 'lasso')
        output_lasso = LASSO(X, Y, gamma);
    elseif strcmp(method, 'scad')
        output_lasso = SCAD(X, Y, gamma);
    elseif strcmp(method, 'mcp')
        output_lasso = MCP(X, Y, gamma);
    end
    FP(1, i) = length(setdiff(find(output_lasso~=0), support));
    FN(1, i) = length(setdiff(support, find(output_lasso~=0)));
    Er(1, i) = sum((output_lasso - beta).^2);
    
    if ~strcmp(model, 'l1-ball')
        if strcmp(method, 'lasso')
            output_lasso_ref = LASSO(X, Y, gamma, false, true);
        elseif strcmp(method, 'scad')
            output_lasso_ref = SCAD(X, Y, gamma, false, true);
        elseif strcmp(method, 'mcp')
            output_lasso_ref = MCP(X, Y, gamma, false, true);
        end
        FP(2, i) = length(setdiff(find(output_lasso_ref~=0), support));
        FN(2, i) = length(setdiff(support, find(output_lasso_ref~=0)));
        Er(2, i) = sum((output_lasso_ref - beta).^2);
    end
    
    output_lasso_naive = DECO(X, Y, m, method, gamma, false, false, false);
    FP(3, i) = length(setdiff(find(output_lasso_naive.coef~=0), support));
    FN(3, i) = length(setdiff(support, find(output_lasso_naive.coef~=0)));
    Er(3, i) = sum((output_lasso_naive.coef - beta).^2);
    
    %product = X*X';
    %F1 = sqrtm(product + 10 * eye(n));
    
    if ~strcmp(model, 'l1-ball')
        output_deco_ref = DECO(X, Y, m, method, gamma, false);
        FP(4, i) = length(setdiff(find(output_deco_ref.coef~=0), support));
        FN(4, i) = length(setdiff(support, find(output_deco_ref.coef~=0)));
        Er(4, i) = sum((output_deco_ref.coef - beta).^2);
    end
    
    output_deco_raw = DECO(X, Y, m, method, gamma, false, false);
    FP(5, i) = length(setdiff(find(output_deco_raw.coef~=0), support));
    FN(5, i) = length(setdiff(support, find(output_deco_raw.coef~=0)));
    Er(5, i) = sum((output_deco_raw.coef - beta).^2);  
    
    disp(['Round ', num2str(i), ' finished!']);
end
end