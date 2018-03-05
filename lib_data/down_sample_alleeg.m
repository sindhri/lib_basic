%take alleeg that was read by read_egi_singletrial_multiplefiles.m
%downsample to destination sampling rate dsr = 250hz

function alleeg_new = down_sample_alleeg(alleeg, dsr)

if nargin==1
    dsr = 250;
end

sr = alleeg(1).srate;
n = floor(sr/dsr);
fprintf('Down sampling from %d Hz to %d Hz, by picking every %d data point\n',...
    sr, dsr, n);

for i = 1:length(alleeg)
    eeg = alleeg(i);
    data = eeg.data;
    [nchan,ndp,ntrial] = size(data);
    ndp_new = floor(ndp/n);
    if i==1
        fprintf('Original datapoint %d, after down sampling %d \n', ndp, ndp_new);
    end
    data_new = zeros(nchan, ndp_new, ntrial);
    for j = 1:nchan
        for m = 1:ntrial
            data_new(j,:,m) = downsample(eeg.data(j,:,m),n);
        end
    end
    eeg.data = data_new;
    eeg.srate = dsr;
    eeg.pnts = ndp_new;
    eeg.times = downsample(eeg.times,n);
    eeg.xmax = eeg.times(length(eeg.times))/1000;
    
    alleeg_new(i) = eeg;
end
end