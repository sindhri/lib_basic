%20200731, changed input cluster and toi to poi
%poi.channel, poi.name, poi.time

%20200326, rewrite to fit for foi_ERSP and foi_ITC
%ITC_recompose_to_fullheadmap

%input: foi_struct
%will modify the previous list to incude the following in each row
%id
%maybes
%oscillation_type
%eventtype
%group_name
%frequency_range

%foi_ERSP(1).data, chan x time x subj
%cluster, which has channel and name
%remove max, useless
%output: doi

function T_out = ITC_fullhead_create_doi_from_foi_fho(foi_struct,poi,...
table_filename)

chan_cluster = poi.channel;
toi = poi.time;
times = foi_struct.times;

nc = length(foi_struct);
subject_list = foi_struct.id;
nsubject = length(subject_list);
data_out = zeros(nsubject,nc);
labels = cell(1);
%no frequency dimension
for i = 1:nc
    data = foi_struct(i).data;
    data = mean(data(chan_cluster,:,:),1); %average across chan_cluster
    toi_index = adjust_toi(toi,times);
    data = mean(data(1,toi_index(1):toi_index(2),:),2); %average across time index
    data = squeeze(data); %nsubject
    data_out(:,i) = data;
    labels{i} = [foi_struct(i).setname '_' poi.name];
end
T_out = table;
T_out.ID = foi_struct(1).id;
T_temp = cell2table(num2cell(data_out));
T_temp.Properties.VariableNames = labels;
T_out = [T_out, T_temp];

if nc>1
    [H,P,~,stats] = ttest(data_out(:,1),data_out(:,2));
    fprintf([foi_struct(1).setname ' vs.' foi_struct(2).setname '\n']);
    if H==0
        fprintf('not significant.\n');
    else
        fprintf('significant.\n');
    end
    fprintf('t(%d)=%.3f, p=%.3f\n',stats.df,stats.tstat,P);
end

if table_filename ~= 'n' 
   writetable(T_out,table_filename,'delimiter','\t');
end

end


%toi = [200,300;...
%400,500;]
%two columns of starting and ending time
function [toi_index,toi_adjusted] = adjust_toi(toi,times)

toi_adjusted = zeros(size(toi));
toi_index = zeros(size(toi));

for i = 1:size(toi,1)
    [toi_index(i,1:2),toi_adjusted(i,1:2),adjusted1] = adjust_range(toi(i,1:2),times);

    if adjusted1 == 1
        fprintf('range of interest %d adjusted to:\n',i);
        fprintf('%d to %d ms\n',poi_adjusted(i,1),...
        poi_adjusted(i,2));
    end
end    
end


%internal function for adjust_poi
function [range_of_interest_index, ...
    range_of_interest_adjusted,adjusted]= adjust_range(range_of_interest,list)

range_of_interest_index = zeros(size(range_of_interest));

range_of_interest_adjusted = range_of_interest;

adjusted = 0;
for i = 1:size(range_of_interest,1) %rows
    for j = 1:size(range_of_interest,2) %columns
        target = range_of_interest(i,j);
        [index,target_adjusted] = find_index(target,list);
        range_of_interest_index(i,j)= index;
        range_of_interest_adjusted(i,j) = target_adjusted;
        if target ~= target_adjusted
            adjusted = 1;
        end
    end
end
end

%internal function for adjust_range
function [index, target_adjusted] = find_index(target, list)
index = 0;
for i = 1:length(list)-1
    diff = list(i)-target;
    if abs(list(i+1) - target) > abs(diff)
        index = i;
        target_adjusted = list(i);
        break;
    end
end
if index==0
    index = length(list);
    target_adjusted = list(length(list));
end
end