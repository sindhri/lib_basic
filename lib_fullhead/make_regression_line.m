function [yhat,pred_ci] = make_regression_line(x,y,x_label,color)

addpath('tstat3/');
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

ylim([40,220]);
xticks([0:20:100]);
xticklabels({'0','20','40','60','80','100'});
ylabel('Food Craving','fontweight','bold');
yticks([50,100,150,200])
yticklabels({'50','100','150','200'});
xlabel(x_label,'fontweight','bold');
hold off

[r,p] = corrcoef(x,y);
text_content = sprintf('r = %.3f, p = %.3f',r(1,2), p(1,2));
t = text(40,210,text_content);

s = t.FontSize;
t.FontSize = 12;
s = t.FontAngle;
t.FontAngle = 'italic';

set(gca,'fontsize',12,'fontname','Arial');
end