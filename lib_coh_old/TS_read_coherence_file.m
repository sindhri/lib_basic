function [data,heading] = TS_read_coherence_file(pathname)

if nargin==0
    pathname = '/Users/Wujia123/Documents/RESEARCH/';
end

[filename, pathname] = uigetfile([pathname '*.tfc'],...
    'choose the coherence file for go_F3 ''xx_go_F3.tfc''');

channel_ref = filename(length(filename)-9:length(filename)-8);

fid = fopen([pathname filename],'r');

frequency_range = 2:20;
channel_list = {'F9','A1','P9','Fp1','F7','T7','P7','O1','F3','C3',...
    'P3','Fpz','Fz','Cz','Pz','Oz','F4','C4','P4','Fp2',...
    'F8','T8','P8','O2','F10','A2','P10'};

m = 1;

for i = 1:length(channel_list)
    if ~strcmp(channel_list{i}, channel_ref)
        channel_list_current{m} = channel_list(i);
        m = m + 1;
    end
end

number_of_channels = length(channel_list)-1;
number_of_frequencies = length(frequency_range);
number_of_time_samples = 101;

fscanf(fid,'%s',13);

for i=1:number_of_channels
    heading{i} = fscanf(fid,'%s',3);
end

for i = 1:number_of_channels
    for j = 1:number_of_frequencies
        data(j,1:number_of_time_samples,i) = fscanf(fid,'%f',number_of_time_samples);
    end
end

fclose(fid);