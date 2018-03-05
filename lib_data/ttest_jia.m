%have all the useful information for paird samples t test.

function tresult = ttest_jia(cond1,cond2)

n = length(cond1);
[h,p,ci,stats] = ttest(cond1,cond2);

tresult.t = stats.tstat;
tresult.df = stats.df;
tresult.p = p;
tresult.ci = ci;

tresult.m1 = mean(cond1);
tresult.se1 = std(cond1)/sqrt(n);
tresult.m2 = mean(cond2);
tresult.se2 = std(cond2)/sqrt(n);
tresult.diff = tresult.m1 - tresult.m2;
tresult.se = stats.sd/sqrt(n);

fprintf('\n*************\n');
if h==1
    fprintf('significnat\n');
    fprintf('t(%d) = %.2f, p = %.4f\n', tresult.df,tresult.t,tresult.p);
    fprintf('cond1 (mean = %.2f uV, SE = %.2f)\n', tresult.m1,tresult.se1);
    if tresult.m1<tresult.m2
        fprintf('is smaller than \n');
    else
        fprintf('is bigger than \n');
    end
    fprintf('cond2 (mean = %.2f uV, SE = %.2f)\n', tresult.m2,tresult.se2);
    fprintf('mean difference = %.2f uV, SE = %.2f\n', tresult.diff, ...
        tresult.se);
else
    fprintf('not significant\n');
    fprintf('t(%d) = %.2f, p = %.4f\n', tresult.df,tresult.t,tresult.p);
    fprintf('cond1 (mean = %.2f uV, SE = %.2f)\n', tresult.m1,tresult.se1);
    fprintf('is not significant different than \n');
    fprintf('cond2 (mean = %.2f uV, SE = %.2f)\n', tresult.m2,tresult.se2);
    fprintf('mean difference = %.2f uV, SE = %.2f\n', tresult.diff, ...
        tresult.se);

end
fprintf('*************\n\n');

%then need to use ?V to replace uV

