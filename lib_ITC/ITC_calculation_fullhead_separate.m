%20130625, fixed a couple bugs, should be cell(n,1) instead of cell(n)
%20130529, use struct as output, ITC_config as input

%20130226, used alleeg as input
%output all_ERSP, all_ITC, n_freq*n_time*n_cond*n_subj
%need to modify the way of getting subject id;
%20140829, added chan_list in the struct

%20140908, pulled in internal functions so its self run
%20141009, added full head support
%20150917, added channel name display for each subject

%20151029, make a result folder and save the results, separate for each
%individual

function ITC_calculation_fullhead_separate(alleeg)


EEG = alleeg(1);

etimes = EEG.times;
group_name = EEG.group_name;

[freqs, n_freqs, n_times, calculation_time_range] = ITC_config(etimes);

calculation_datapoint_range = adjust_range(calculation_time_range,etimes);
datapoint_start = calculation_datapoint_range(1);
datapoint_end = calculation_datapoint_range(2);

nbchan = EEG.nbchan;
fprintf('analysis is conducted on %d channels\n',nbchan);
channames = cell(1);
for i = 1:nbchan
    channames{i} = EEG.chanlocs(i).labels;
end
if nbchan < 10
    for i = 1:nbchan
        fprintf('%s\n',channames{i});
    end
    fprintf('\n');
else
    fprintf('from %s to %s\n\n',channames{1}, channames{nbchan});
end

n_subj = length(alleeg);

all_ERSP = zeros(n_freqs, n_times, nbchan);

all_ITC_z = zeros(n_freqs, n_times, nbchan);

category_names = EEG.category_names;

ITC_struct_base.group_name = group_name;
ITC_struct_base.category_names = category_names;
n_category = length(category_names);
ITC_struct_base.freqs = freqs;
ITC_struct_base.srate = EEG.srate;
ITC_struct_base.nfreqs = n_freqs;
ITC_struct_base.ntimes =n_times;
ITC_struct_base.baseline = EEG.baseline;
ITC_struct_base.ERSP_category = cell(n_category,1);
ITC_struct_base.ITC_category = cell(n_category,1);
ITC_struct_base.channames = channames;
ITC_struct_base.nbchan = nbchan;





if ~exist('result','dir');
    mkdir('result')
end

for i = 1:n_subj
    EEG = alleeg(i);
    id = EEG.id;
    category_names_count = EEG.category_names_count;

    for j = 1:n_category
        for p = 1:nbchan
            fprintf('\n\nprocessing %s, category %s, channal %s\n\n\n',id,category_names{j},channames{p});
            chan_list = p;

            trial_index = category_names_count{j,3};
            [ERSP,ITC,~,times,freqs]=newtimef(mean(EEG.data(chan_list,...
            datapoint_start:datapoint_end,trial_index),1), ...
            datapoint_end - datapoint_start + 1,calculation_time_range,...
            EEG.srate, [3, 0.5], 'nfreqs',n_freqs, 'freqs', freqs,...
            'timesout',n_times,'baseline',[-EEG.baseline,0],'plotitc','off',...
            'plotersp','off');

            ITC=abs(ITC);       
            ITC_z = r_to_z_4d(ITC);
            
            all_ERSP(:,:,p) = ERSP;
            all_ITC_z(:,:,p) = ITC_z;
        end
        
        ITC_struct = ITC_struct_base;
        ITC_struct.ERSP = all_ERSP;
        ITC_struct.ITC = all_ITC_z;
        ITC_struct.id = id;
        ITC_struct.times = times;
        if ~isempty(group_name)
            group_name = [group_name ' '];
        end
        ITC_struct.ERSP_category{1,1} = [group_name 'ERSP ' category_names{j}];
        ITC_struct.ITC_category{1,1} = [group_name 'ITC ' category_names{j}];
        save(['result/struct_' id '_' category_names{j}], 'ITC_struct');
    end
end


end






function [index_range_of_interest, ...
    range_of_interest_adjusted]= adjust_range(range_of_interest,list)

index_range_of_interest = zeros(size(range_of_interest));

range_of_interest_adjusted = range_of_interest;

adjusted = 0;
for i = 1:size(range_of_interest,1)
    for j = 1:size(range_of_interest,2)
        target = range_of_interest(i,j);
        [index,target_adjusted] = find_index(target,list);
        index_range_of_interest(i,j)= index;
        range_of_interest_adjusted(i,j) = target_adjusted;
        if target ~= target_adjusted
            adjusted = 1;
        end
    end
end

fprintf('range of interest');
if adjusted == 1
    fprintf(' adjusted to: ');
end
fprintf('\n');
for i = 1:size(range_of_interest,1)
    for j = 1:size(range_of_interest,2)
        if mod(j,2) == 1
            fprintf('from ');
        else
            fprintf(' to ');
        end
        fprintf('%d',range_of_interest_adjusted(i,j));
    end
fprintf('\n');
end

end

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



%convert ITC(r) to z

function data_z = r_to_z_4d(data)

data_z = zeros(size(data));

for a = 1:size(data,1)
    for b = 1:size(data,2)
        for c = 1:size(data,3)
            for d = 1:size(data,4)
                data_z(a,b,c,d) = r_to_z(data(a,b,c,d));
            end
        end
    end
end

end

function z = r_to_z(x)

z = 1/2*log((1+x)/(1-x));
end