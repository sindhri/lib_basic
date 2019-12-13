%20170920, read the folder of ave files.
%20171128, downsample option to 250hz 
%20180502, adjusted EEG.times to be downsampled as well
%20191017, changed category_names to eventtypes, id to ID
%so that it's consistent with the names in the further fullhead analysis
%20191111, changed ID to interger

function EEG_ave = ITC_read_egi_ave(eventtypes,baseline,...
    group_name,ID_type,net_type,pathname,downsample_to)

    if nargin == 5
        pathname = uigetdir(pwd);
        pathname = [pathname '/'];
    end
    
    ALLEEG = ITC_read_egi(eventtypes,baseline,...
    group_name,ID_type,net_type,pathname,'ave');

    if nargin< 7
        downsample_to = ALLEEG(1).srate;
    end
    
    [nbchan,ndpt,ncond] = size(ALLEEG(1).data);

    if ALLEEG(1).srate== downsample_to
        data = zeros(nbchan,ndpt,ncond,length(ALLEEG));
    else
        downsample_rate = ALLEEG(1).srate/downsample_to;
        data = zeros(nbchan,ndpt/downsample_rate,ncond,length(ALLEEG));
    end


for i = 1:length(ALLEEG)
    if ALLEEG(i).srate ~= downsample_to
       downsample_rate = ALLEEG(i).srate/downsample_to;
        data_temp = downsample_EEG(ALLEEG(i).data,downsample_rate);
        if i == 1
            EEG_ave.times = downsample_EEG(ALLEEG(1).times,downsample_rate);
        end
    else
        data_temp = ALLEEG(i).data;
        if i==1
            EEG_ave.times = ALLEEG(1).times;
        end
    end
    data(:,:,:,i) = data_temp;
    %ID{i} = ALLEEG(i).id; 
    %20191111
    ID(i) = str2double(ALLEEG(i).id);
end

EEG_ave.data = data;
EEG_ave.ID = ID;
EEG_ave.chanlocs = ALLEEG(1).chanlocs;
EEG_ave.eventtypes = ALLEEG(1).category_names;
EEG_ave.nbchan = ALLEEG(1).nbchan;
if ALLEEG(1).srate == downsample_to
    EEG_ave.pnts = ALLEEG(1).pnts;
    EEG_ave.srate = ALLEEG(1).srate;
else
    EEG_ave.pnts = ALLEEG(1).pnts/downsample_rate;
    EEG_ave.srate = downsample_to;
end
EEG_ave.xmin = ALLEEG(1).xmin;
EEG_ave.xmax = ALLEEG(1).xmax;
EEG_ave.group_name = ALLEEG(1).group_name;
EEG_ave.nsubject = length(ALLEEG);

end

function data_new = downsample_EEG(data,rate) %nchan x ndpt x ncond
    [nchan, ~, ncond] = size(data);
    for i = 1:nchan
        for j = 1:ncond
            data_new(i,:,j) = downsample(data(i,:,j),rate);
        end
    end
end