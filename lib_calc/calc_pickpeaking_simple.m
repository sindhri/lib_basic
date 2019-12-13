%20170117
%input eeg.data format, chan x datapoint x condition x subject
%also need to have the filed times.
%output, subject x condition x poi

%of a giving peak, first search -50 to 50ms
%%20191211, input data: nchan x ndpt x ncond x nsubj
%input only one poi
%poi.cluster is the channel cluster
%poi.time is the time period of interest
%input times, time index for the data

%input polarity, '+', or '-'

%output is the peak amplitude at the poi: ncond x nsubj
%also output the peak latency within the poi: ncond x nsubj


function [peak_amplitude,peak_latency] = calc_pickpeaking_simple(data,times,poi,polarity)

[~,~,ncond,nsubject] = size(data);

toi = poi.time;
choi = poi.cluster;
[toi_index,~] = adjust_toi(toi,times);

data_avgchantoi = mean(data(choi,toi_index(1):toi_index(2),:,:),1);
peak_amplitude = zeros(ncond,nsubject);
peak_latency = zeros(ncond,nsubject);

for i = 1:ncond
    for j = 1:nsubject
        input_data = data_avgchantoi(1,:,i,j);
        if polarity == '+'
            [peaks,peak_latencyindexes] = findpeaks(input_data);
            if ~isempty(peaks)
                [maxpeak,maxpeakindex] = max(peaks);
                peak_amplitude(i,j) = maxpeak;
                peak_latency(i,j) = times(peak_latencyindexes(maxpeakindex)+toi_index(1));
            else
                [peak_amplitude(i,j),peak_latency(i,j)] = max(input_data);
                fprintf('cond%d,subj%d no peak found, used maximum value\n',i,j);
            end
        elseif polarity == '-'
                [peaks,peak_latencyindexes] = findpeaks(-input_data);
                if ~isempty(peaks)
                    [maxpeak,maxpeakindex] = max(peaks);
                    peak_amplitude(i,j) = -maxpeak;
                    peak_latency(i,j) = times(peak_latencyindexes(maxpeakindex)+toi_index(1));
                else
                    [peak_amplitude(i,j),peak_latency(i,j)] = min(input_data);
                    fprintf('cond%d,subj%d no peak found, used minumum value\n',i,j);
                end
        end
    end
end
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