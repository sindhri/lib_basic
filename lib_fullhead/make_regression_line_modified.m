function [yhat,pred_ci] = make_regression_line_modified(x,y,color)

%addpath('tstat3/');
DM = [ones(size(x(:))), x(:),];                             % Design Matrix
B = DM \ y(:);                                              % Estimate PArameters
yhat = DM*B;                                                % Predicted Regression Values
d = y(:) - yhat;                                            % Calculate Residuals
mx = mean(x);                                               % Mean
n = length(x);                                              % Vector Length
v = n-2;                                                    % Degrees-Of-Freedom
tp = 0.95;                                                 % 95% Confidence Intervals
tv = tstat3( v, tp, 'inv');                                 % t-Value (Download ?tstat3?)
pred_ci = tv*sqrt((sum(d.^2)/v) .* ((1/n) + ((x(:)-mx).^2)./(sum((x(:)-mx).^2))));

plot(x, y, ['.' color],'markersize',10);
hold on
plot(x, yhat, color,'linewidth',1);
temp = [x,yhat+pred_ci,yhat-pred_ci];
[~,index] = sort(temp(:,1)); %sort! Jia added 20180816
temp2 = yhat+pred_ci;
plot(x(index), temp2(index) , ['-' color],'markersize',4);
temp2 = yhat-pred_ci;
plot(x(index), temp2(index), ['-' color],'markersize',4);



[r,p] = corrcoef(x,y);
text_content = sprintf('r = %.3f, p = %.3f',r(1,2), p(1,2));
xl = xlim;
yl = ylim;
t = text(0,yl(2)*0.9,text_content);

s = t.FontSize;
t.FontSize = 12;
s = t.FontAngle;
t.FontAngle = 'italic';

set(gca,'fontsize',12,'fontname','Arial');
end