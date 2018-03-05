%data is channel x datapoint x subject
%rating is subject x value
%2011-09-07, added count for sig without FDR.

%2012-02-29
%added dependency as a parameter, so it calculates negative dependency

%2013-05-01
%added squeeze the data

%2013-11-19
%added to eliminate nan

%20160802, added srate
%removed alleeg dependency, input baseline and srate

function report = do_cond_rating_fdr_2017(data, rating, data_id, ...
    rating_id, baseline,srate, subject_list, dependency,channel_list)


baseline_dps = baseline/(1000/srate); %in terms of datapoint

if nargin>=6
    picked_unnan = ~isnan(rating);
    rating = rating(picked_unnan);
    rating_id = rating_id(picked_unnan);
end

if nargin==6
    subject_list = rating_id;
    dependency = 'pdep';
    chan_list = 1:129;
end

if nargin ==7
    dependency = 'pdep';
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

if nargin>4
    [data, rating, subject_list] = preprocess_unmatched_data_rating(data,...
        rating, data_id, rating_id, subject_list);
else
    [data, rating] = eliminate_zero(data, rating);
    subject_list = 1:length(rating);
    dependency = 'pdep';
end


if nargin<9
    channel_list = read_channelclusters;
    channel_list = squeeze(channel_list{1});
end

data = squeeze(data);
[~,ndatapoint,~] = size(data);

data = data(channel_list, baseline_dps+1 : ndatapoint,:);


[nchan,ndatapoint,~] = size(data);
fprintf('revised channel number is %d, revised datapoint number is %d\n',...
    nchan, ndatapoint);

r_list = zeros(nchan, ndatapoint);
p_list = zeros(nchan, ndatapoint);
p_list_sign = zeros(nchan, ndatapoint);

for i = 1:nchan
    for j = 1:ndatapoint
        temp_data = squeeze(data(i,j,:));

        n = length(temp_data);
        
        [r,p] = corrcoef(temp_data, rating);
        r_list(i,j) = r(1,2);
        p_list(i,j) = p(1,2);
        if r_list(i,j) > 0
            p_list_sign(i,j) = p_list(i,j);
        else
            p_list_sign(i,j) = - p_list(i,j);
        end
    end
    if mod(i,10) == 0
        fprintf('complete chan %d......\n',i);
    end
end

count = count_sig(p_list);
fprintf('%d tests were significant without FDR\n', count);
report.sigwithoutFDR = count;

[report.FDR_h, report.FDR_crit_p, report.FDR_adj_p]=fdr_bh(p_list,0.05,...
    dependency,'yes');
report.channel_list = channel_list;
report.p_list = p_list;
report.p_sign = p_list_sign;
report.r_list = r_list;
report.n = n;
if nargin>2
    report.subject_list = subject_list;
end