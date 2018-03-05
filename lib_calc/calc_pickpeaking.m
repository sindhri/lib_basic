%20170117
%input eeg.data format, chan x datapoint x condition x subject
%output, subject x condition x poi

%of a giving peak, first search -50 to 50ms
%if not found--latency falls on either edge, increase the range to -100 to
%100 ms

%still not perfect, 

%input poi, place of interest, composed of time and channel cluster
%poi(1).time = 200;
%poi(1).cluster = [11,12,5,6];
%poi(1).cluster_name = 'Fz';
%poi(1).direction = -1; %negative

%20171129, revise, add output structure to easy access the numbers

function [output,output_struct] = calc_pickpeaking(alleeg,poi)

data = alleeg.data;
ncond = size(data,3);
nsubject = size(data,4);
times = alleeg.times;
npoi = length(poi);
output = zeros(nsubject,ncond,npoi*2);

if isfield(alleeg,'ID')
    subject_list = alleeg.ID;
else
    subject_list = alleeg.id;
end

for i = 1:npoi
    toi = poi(i).time;
    choi = poi(i).cluster;
    direction = poi(i).direction;
    data_avgchan = mean(data(choi,:,:,:),1);
    
    
    for m = 1:ncond
        for n = 1:nsubject
            data_avgchan_1dim = squeeze(data_avgchan(1,:,m,n)); %to 1-dimension
            [amplitude,latency] = peak_picking_multiple(data_avgchan_1dim,toi,direction,times);
            output(n,m,(i-1)*2+1) = amplitude;
            output(n,m,i*2) = latency;    
        end
    end
    
    %do not squeeze without caution, sometimes there is one condition,
    %sometimes there is one subject
 
end

output_struct.data = output;
output_struct.id = subject_list;
output_struct.poi = poi;

end

function [amplitude, latency] = peak_picking_multiple(data_avgchan,toi,direction,times)
    peak_toi_50 = [toi-50,toi+50];
    [toi_index_50,toi_adjusted] = adjust_toi(peak_toi_50,times);
    data_for_picking_50 = data_avgchan(toi_index_50(1):toi_index_50(2));
    [amplitude_50,latency_index_50] = peak_picking(data_for_picking_50,direction);
   
     peak_toi_100 = [toi-100,toi+100];
    [toi_index_100,toi_adjusted] = adjust_toi(peak_toi_100,times);
    data_for_picking_100 = data_avgchan(toi_index_100(1):toi_index_100(2));
    [amplitude_100,latency_index_100] = peak_picking(data_for_picking_100,direction);
    
    amplitude = amplitude_50;
    latency = times(latency_index_50+toi_index_50(1)-1);
    
    if latency_index_50==1 || latency_index_50 == length(data_for_picking_50)
        amplitude = amplitude_100;
        latency = times(latency_index_100+toi_index_100(1)-1);
    end
end

function [amplitude,latency] = peak_picking(data,direction)
    if direction == -1 %negative peak
        amplitude = min(data);
    else
        amplitude= max(data);
    end
    
    latency = find(data == amplitude,1);
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