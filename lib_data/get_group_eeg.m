%get the eeg that belongs to the group
%match alleeg(1,i).id and group{i,1}
function [eeg,group] = get_group_eeg(alleeg)

group = get_group;

eeg = struct;
m = 1;

for i = 1:length(alleeg)
    id = alleeg(1,i).id;

    if check_id_in_list(id,group) == 1
        if m==1
            eeg = alleeg(1,i);
        else
            eeg(m) = alleeg(1,i);
        end
        m = m + 1;
    end
end

end

function found = check_id_in_list(id,group)
    found = 0;
    for i = 1:length(group)
        if strcmp(id,group{i,1})==1
            found = 1;
        end
    end
end

%20130528
%no input, select the group file, which is a tab-delimiter text file with
%one subject id on each line. the type of the group is the name of the
%file.

%output a cell array, each one contains one id.

function group = get_group

    [filename,pathname] = uigetfile('*.txt','select the group file');
    fid = fopen([pathname filename],'r');
    group = textscan(fid, '%s', 'delimiter','\n');
    group = group{1,1};
end