%data is channel x datapoint x subject
%rating is subject x value
%2011-09-07, added count for sig without FDR.

%2012-02-29
%added dependency as a parameter, so it calculates negative dependency

%2013-05-01
%added squeeze the data

%2013-11-19
%added to eliminate nan

%2014-07-19
%do simple correlation with the ability to manage the list
%data, cond x subj

function report = do_cond_rating(data, rating, data_id, ...
    rating_id, subject_list)

if nargin>=4
    picked_unnan = ~isnan(rating);
    rating = rating(picked_unnan);
    rating_id = rating_id(picked_unnan);
end

if nargin==4
    subject_list = rating_id;
end


if iscell(data_id)
    data_id = convert_cell_to_double(data_id);
end
if iscell(rating_id)
    rating_id = convert_cell_to_double(rating_id);
end
if iscell(subject_list)
    subject_list = convert_cell_to_double(subject_list);
end

if nargin>2
    [data, rating, subject_list] = preprocess_unmatched_data_rating(data,...
        rating, data_id, rating_id, subject_list);
else
    [data, rating] = eliminate_zero(data, rating);
    subject_list = 1:length(rating);
end


data = squeeze(data);
[ncond] = size(data,1);

r_list = zeros(1,ncond);
p_list = zeros(1,ncond);

for i = 1:ncond
    [r,p] = corrcoef(data(i,:), rating);
    r_list(1,i) = r(1,2);
    p_list(1,i) = p(1,2);
end

count = count_sig(p_list);
fprintf('%d tests were significant without FDR\n', count);
report.sigwithoutFDR = count;

[report.FDR_h, report.FDR_crit_p, report.FDR_adj_p]=fdr_bh(p_list,0.05,...
    'pdep','yes');
report.p_list = p_list;
report.r_list = r_list;
report.n = size(data,1);
if nargin>2
    report.subject_list = subject_list;
end