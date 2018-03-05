%20170927, input two data and two id
%do correlation, report missing data
%20171003, added output measure1 and measure 2 for confirmation
%20171004, added outlier removal
%20171109, added the option of not removing outlier.
%20171116, updated with preprocess_unmatched_data_rating_v3
function [measure1, measure2] = do_coorcoef_single(measure1,measure2,...
    id1,id2,to_remove_outlier,plot_title)

[measure1, measure2,subject_list] = preprocess_unmatched_data_rating_v3(measure1,...
    measure2, id1, id2);
if nargin == 4
    to_remove_outlier =0;
end
if to_remove_outlier == 1
    [measure1,measure2,subject_list,~] = remove_outlier(measure1,...
       measure2,subject_list,subject_list);
end
[R,P] = corrcoef(measure1, measure2);
r = R(1,2);
p = P(1,2);

if p < 0.05
    fprintf('significant.\n');
else
    fprintf('not signifiant\n');
end

fprintf('r = %.4f, p = %.4f, n = %d\n',r,p,length(subject_list));
figure;
scatter(measure1, measure2);
lsline;
title(plot_title);
end