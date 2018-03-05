%2013-05-06
%average amplitude based on spatial temporal pca result
%need to input manually for each interested component
%need more work, maybe put the selective on the data_avgtime,
%data_avgchannel level


%input 1, data, chan x datapoint x cond x subject
%input 2, time window
%input 3, cluster

%input foi_struct.times, so it's easy to average data
%input foi_struct.data: chan x time x cond x subj
%input factor_time, from last step, post_stpca_get_params
%input channel_clusters, from last step, post_stpca_get_params

%poi_list is an array
%poi_list each rows representing one interest, has 3 elements, nth_TF, nth_SF, polarity
%input nth_TF, the nth temproal factor interested
%input nth_SF, the nth spatial factor interested
%input poloarity, spatial loadings positive or negative, 1 or -1

function output = post_stpca_export_poi(foi_struct,...
    factor_time,channel_clusters,poi_list)

data = foi_struct.data_stpca;
[~,~,ncond,nsubj] = size(data);
npoi = size(poi_list,1);
data_new = zeros(npoi,ncond,nsubj);

for i = 1:npoi
    fprintf('%d\n',i);

    nth_TF = poi_list(i,1);
    nth_SF = poi_list(i,2);
    polarity = poi_list(i,3);
    
    data_temp = average_on_one_time(data,factor_time(nth_TF,:),foi_struct.times);

    if polarity == 1
        channel = channel_clusters{nth_TF,1}{1,nth_SF}.channel;
    else
        channel = channel_clusters{nth_TF,1}{2,nth_SF}.channel;
    end

    data_new(i,:,:) = mean(data_temp(channel,:,:),1);
    %result: ninterest x ncond x nsubject
end


%input npoi x ncond x nsubj
%output nsubj x (ncond x npoi)

output.data = zeros(nsubj,ncond*npoi);
output.label = cell(1);
for i = 1:nsubj
    n = 1;
    for m = 1:npoi
        for j = 1:ncond
            output.data(i,n) = data_new(m,j,i);
            if poi_list(m,3)==1
                polarity = 'p';
            else
                polarity = 'n';
            end
            if i==1
                temp = foi_struct.category_names{j};
                if iscell(temp) %fix the messed up structure for category names from IE merge
                    temp = temp{1};
                end
                output.label{n} = strcat(foi_struct.type,...
                    foi_struct.name_for_column,...
                    'TF',num2str(poi_list(m,1)),...
                    'SF',num2str(poi_list(m,2)),...
                    polarity,...
                    temp);
            end
            n = n + 1;
        end
    end
end
output.id = foi_struct.id;
export_output(output);
end


%input data: chan * times * nc *ns
%output data: chan * factor_times * nc * ns
function data_avg = average_on_one_time(data,toi,times)
        toi_index = find_valid_pos(toi,times);

        t1 = times(toi_index(1));
        t2 = times(toi_index(2));

        toi_name = [int2str(t1), ' to ' int2str(t2), 'ms'];
        fprintf('time of interest is adjusted to:\n%s\n', toi_name);

        data_avg= squeeze(mean(data(:,toi_index(1):toi_index(2),:,:),2)); 
    %input data: chan * times * nc *ns
    %output data: chan x nc x ns
end

function [items_pos, items_adjusted] = find_valid_pos(items,list)
    n = length(list);
    items_pos = round( (items-list(1))/(list(n)-list(1)) * (n-1))+1;
    items_pos(find(items_pos<1))=1;
    items_pos(find(items_pos>n))=n;
    items_adjusted = list(items_pos);
end

%export output struct
%output.data is nsubj x m
%output.label is 1xm
%output.id is nsubjx1

%problem with export was because column name too long???invalid
%names?'error'
%cell structure of label set up wrong!because of IE merge.
function export_output(output)
    d = dataset({output.data,output.label{:}},'obsnames',output.id);
    export(d,'file','export.txt');
end
