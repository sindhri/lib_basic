%20170927, input two data and two id
%do independent samples t test, report missing data
%20171109, added some more text
%20171115, updated process_unmatched_data_rating to v3 to allow strings
function do_2group_single(measure1,measure2,id1,id2)

%[measure1, measure2,subject_list] = preprocess_unmatched_data_rating_v3(measure1,...
%    measure2, id1, id2);

[~,P,~,STATS] = ttest2(measure1, measure2);
t = STATS.tstat;
p = P;

if p < 0.05
    fprintf('condition difference significant.\n');
else
    fprintf('condition difference not signifiant\n');
end

fprintf('t = %.2f, p = %.3f, n = %d\n',t,p,length(id1) + length(id2));
figure;
bar([mean(measure1), mean(measure2)]);

end