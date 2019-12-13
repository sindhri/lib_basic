%if single channel, convert to string
%if cluster, use the first channel + andother
%output a structure with name and channel
%20190331, use 10-20 system to auto-name clusters

function montage = coh_get_channel_pair_names2(channels)

    keySet = [22, 9, 33, 24, 124, 122, 45, 36, 104, 108, 58, 52, 92, 96, 70, 83];
    valueSet = {'Fp1','Fp2','F7','F3','F4',...
    'F8','T3','C3','C4','T4','P5','P3',...
    'P4','T6','O1','O2'};
    channel_name_mapping = containers.Map(keySet,valueSet);

    channel_names = cell(1);

    for i = 1:length(channels)
        temp = channels{i};
        channel_names{i} = [channel_name_mapping(temp{1}) channel_name_mapping(temp{2})];
    end
    
    montage.name = channel_names;
    montage.channel = channels;
end