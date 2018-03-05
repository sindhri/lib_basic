%use ITC_read_egi to read the raw format of individual average file
%then compute the mean amplitude
%poi is place of interest
%each cell has the channel cluster and time 
%poi = {'fz',[11,12,5,6],[200,500];...
%    'cz',[31,129,80,55],[200,500];...
%    'pz',[72,71,76,75],[200,500]};


function output = ERP_calculate_mean_amplitude(ALLEEG, poi)
times = ALLEEG(1).times;
nsubj = length(ALLEEG);
group_name = ALLEEG(1).group_name;
category_names = ALLEEG(1).category_names;
[nchan,ndpt,ncond] = size(ALLEEG(1).data);

data = zeros(nchan,ndpt,ncond,nsubj);
id=cell(1);
for i = 1:length(ALLEEG)
    data(:,:,:,i) = ALLEEG(i).data;
    id{i} = ALLEEG(i).id;
end
npoi = size(poi,1);
output1= zeros(ncond,nsubj,npoi);
label1=cell(1);
for i = 1:npoi %number of poi
    channel_needed = poi{i,2};
    time_needed = poi{i,3};
    time_print=[int2str(time_needed(1)) '_' int2str(time_needed(2)) 'ms'];
    time_needed_index = adjust_range(time_needed,times);
    data_temp = squeeze(mean(data(channel_needed,:,:,:),1)); %average on channels
    data_temp2 = squeeze(mean(data_temp(time_needed_index(1):time_needed_index(2),:,:),1)); %average on time
    output1(:,:,i) = data_temp2;
    for j = 1:ncond
        label1{j,i}=[category_names{j} '_' poi{i,1} '_' time_print];
    end
end

output2 = zeros(nsubj,npoi*ncond);
label2 = cell(1,npoi*ncond);
for i = 1:ncond
    output2(:,(i-1)*npoi+1:i*npoi)=squeeze(output1(i,:,:));
    label2(1,(i-1)*npoi+1:i*npoi) = label1(i,:);
end

output.data= output2;
output.id=id;
output.label=label2;

d = dataset({output2,label2{:}},'obsnames',id);
if ~isempty(group_name)
    export(d,'file',['export_' group_name '.txt']);
else
    export(d,'file','export.txt');
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
            fprintf('target is %.2f, adjusted to %.2f\n',target,target_adjusted);
            adjusted = 1;
        else
            fprintf('target %.2f found the exact match\n',target);
            adjusted = 0;
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