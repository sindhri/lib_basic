%20170117
%input eeg.data format, chan x datapoint x condition x subject
%output, subject x condition x poi


%input poi, place of interest, composed of time and channel cluster
%poi(1).time = [300,500];
%poi(1).cluster = [11,12,5,6];
%poi(1).cluster_name = 'Fz';

%20170929, included field 'id'
%output the data for the eported file, and for copy-paste, also output the struct

%20171108, added options if subject_list is double
%20171130, added name for exported file

function [output_data,output_struct] = calc_avgtimechan(alleeg,poi)

data = alleeg.data;
ncond = size(data,3);
nsubject = size(data,4);
times = alleeg.times;
npoi = length(poi);
output_data = zeros(nsubject,ncond,npoi);


for i = 1:npoi
    toi = poi(i).time;
    choi = poi(i).cluster;
    %choi_name = poi(i).cluster_name;
    [toi_index,toi_adjusted] = adjust_toi(toi,times);
    data_avgtime = mean(data(:,toi_index(1):toi_index(2),:,:),2);
    data_avgtimechan = mean(data_avgtime(choi,:,:,:),1);
    %do not squeeze without caution, sometimes there is one condition,
    %sometimes there is one subject
    for m = 1:ncond
        for n = 1:nsubject
            output_data(n,m,i) = data_avgtimechan(1,1,m,n);
        end
    end
end

data_2d = [];
for i = 1:npoi
    data_2d = [data_2d, output_data(:,:,i)];
end

label = cell(1);
m = 1;
for i = 1:npoi
    for j = 1:ncond
        label{m} = [poi(i).cluster_name '_' alleeg.category_names{j}];
        m = m+1;
    end
end
if isfield(alleeg,'ID')
subject_list = alleeg.ID;
else
subject_list = alleeg.id;
end

d = dataset({data_2d,label{:}},'obsnames',subject_list);
exported_filename = ['export_' alleeg.group_name '_' poi.cluster_name '.txt'];
export(d,'file',exported_filename);

output_struct.data = output_data;
output_struct.id = subject_list;
output_struct.poi = poi;

end

function [toi_index,toi_adjusted] = adjust_toi(toi,times)

    [toi_index,toi_adjusted,adjusted_boolean] = adjust_range(toi,times);

    if adjusted_boolean == 1
        fprintf('time of interest %d ms to %d ms adjusted to %d ms to %d ms:\n',...
            toi(1),toi(2),toi_adjusted(1),toi_adjusted(2));
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