function r = TuneRidge(X, Y, fold, n, nlambda, p, noTune)
    if p == 0
        r = 0;
        return
    end
    V = floor(n/fold);
    lambda = 0:(1/nlambda):1;
%     COND = zeros(1, nlambda);
%     AVE_COND = zeros(1,nlambda);
%     for i = 1:nlambda
%         r = lambda(i);
%         values = eig(X'*X + r*n*eye(p));
%         COND(i) = max(values)/min(values)/p;
%         AVE_COND(i) = sum(values)/min(values)/p;
%     end
%     lambda = lambda(union(find(COND<25/60), find(AVE_COND<5)));
%     if noTune == true
%         if ~isempty(lambda)
%             r = lambda(1);
%         else
%             r = 1;
%         end
%         return
%     end
%     nlambda = length(lambda);
    cv = zeros(nlambda, fold);
    for i = 1:fold
        TEST = (V*(i - 1) + 1):V*i;
        TRAIN = setdiff(1:n, TEST);
        X1 = X(TRAIN,:);
        Y1 = Y(TRAIN,:);
        X2 = X(TEST,:);
        Y2 = Y(TEST,:);
        for j = 1:nlambda
            r = lambda(j);
            cv(j,i) = sum((X2*((X1'*X1 + r*n*eye(p))\(X1'*Y1))...
                - Y2).^2)/length(TEST);
        end
    end
    res = mean(cv,2);
    [~,index] = min(res);
    r = lambda(index);
end