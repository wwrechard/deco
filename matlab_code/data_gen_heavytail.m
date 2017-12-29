function [X, Y, beta] = data_gen_heavytail(n, p, s, type, R2, r)
% Same as data_gen but the noise follows t-distribution.
% See 'help data_gen'
    if nargin == 2
        s = 5;
        type = 'ind';
        R2 = 0.95;
        r = 0;
    elseif nargin == 3
        type = 'ind';
        R2 = 0.95;
        r = 0;
    elseif nargin == 4
        R2 = 0.9;
        if strcmp(type, 'corr') || strcmp(type, 'l1-ball'), r = 0.6;
        elseif strcmp(type, 'group'), r = 3;
        elseif strcmp(type, 'factor'), r = 5;
        end
    elseif nargin == 5
        if strcmp(type, 'corr') || strcmp(type, 'l1-ball'), r = 0.6;
        elseif strcmp(type, 'group'), r = 3;
        elseif strcmp(type, 'factor'), r = 5;
        end
    end
    
    
    beta = zeros(p,1);
    beta(1:s) = (abs(normrnd(0,1,s,1)) + 5*log(p)/sqrt(n)).*2.*((rand(s,1)>0.5)-0.5);
    if strcmp(type, 'ind')
        X = normrnd(0,1,n,p);
        
    elseif strcmp(type, 'corr')    
        rho = sqrt(r/(1-r));
        X1 = normrnd(0,1,n,p);
        x = normrnd(0,1,n,1);
        X = X1+x*ones(1,p)*rho;
        
    elseif strcmp(type, 'group')
        gr = r; %number of groups
        rho = 0.01; %correlation within each group.
        beta = zeros(p,1);
        %beta(1:(gr*s)) = (abs(normrnd(0,1,gr*s,1)) + 2).*2.*((rand(gr*s,1)>0.5)-0.5);
        beta(1:(gr*s)) = 3;
        X1 = normrnd(0,1,n,p);
        X = X1;
        for i = 1:gr
            for j = 1:s
                X(:,s*(i-1)+j) = X1(:,s*(i-1)+1) + normrnd(0,1,n,1)*sqrt(rho);
            end
        end
        
    elseif strcmp(type, 'factor')
        X1 = normrnd(0,1,n,p);
        W = normrnd(0,1,n,r);
        X = X1 + W*normrnd(0,1,r,p);
        
    elseif strcmp(type, 'timeseries')
        beta = zeros(p,1);
        beta(1) = 1;
        beta(5) = -3;
        beta(10) = 2;
        rho = 0.7;
        X = normrnd(0,1,n,p);
        for k = 2:p
            X(:,k) = rho*X(:,k-1) + sqrt(1-rho^2)*X(:,k);
        end
    elseif strcmp(type, 'partial')
        beta = zeros(p, 1);
        beta([1,p]) = [10, 1];
        %beta(1:4) = [0.02 0.2 -0.2 -0.2]'; 
        %beta(1:4) = (abs(normrnd(0,1,4,1)) + 1).*2.*((rand(4,1)>0.5)-0.5);
        r = 0.9;
        rho = sqrt(r/(1-r));
        X1 = normrnd(0,1,n,49);
        x = normrnd(0,1,n,1);
        X = (X1+x*ones(1,49)*rho)/sqrt(1 + rho^2);
        X = [normrnd(0,1,n,1) X normrnd(0,1,n,p-50)]; 
%         X1 = normrnd(0,1,n,7);
%          x = normrnd(0,1,n,1);
%          X = (X1+x*ones(1,7)*rho)/sqrt(1 + rho^2);
%          X = [X normrnd(0,1,n,p-7)];

    elseif strcmp(type, 'l1-ball')
        beta = zeros(p, 1);
        for i = 1:p
            beta(i) = gamrnd(1/p, 1);
        end
        beta = beta/sum(beta) * 10;
        
        rho = sqrt(r/(1-r));
        X1 = normrnd(0,1,n,p);
        x = normrnd(0,1,n,1);
        X = X1+x*ones(1,p)*rho;
    end
    e = trnd(3, n, 1);
    link = X*beta;
    sigma = sqrt(var(link)*(1-R2)/R2);
    %sigma = sqrt(sum(beta.^2)/5.7);
    Y = X*beta + sigma*e;
end