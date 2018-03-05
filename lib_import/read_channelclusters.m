%copy and paste the rotated matrix in a text editor and save as rft.
%able to parse the rotated matrix based on inner symbol by rtf file.
%without knowing the length of data

%make sure the file ends without any symbols, etc, no extra line...

function channels = read_channelclusters(pathname,filename)

if nargin==0
    [filename, pathname] = uigetfile([pwd '/.rtf'],'choose the channel cluster file');
end

fid = fopen([pathname filename],'r');
file_has_data = 'false';

while(1)
    temp = fscanf(fid,'%d',1);
    if isempty(temp)
        temp2 = fscanf(fid,'%s',1);
        if strcmp(temp2(1:3),'all')
            channel_array = 1:129';
            break
        end
    else
        channel_array(1,1)=temp;
        file_has_data = 'true';
        break
    end
end

if strcmp(file_has_data,'true')
    tr = 1;
    td = 2;
    while(1)
        temp = fscanf(fid,'%c',1);
        if strcmp(temp,'\')
            tr = tr+1;
            td = 1;
        else
            if strcmp(temp,'}')
                break
            end
        end
        channel_array(tr,td) = fscanf(fid,'%d',1);
        td = td+1;
    end
end
fclose(fid);

for i=1:size(channel_array,1)
    channels{i,1} = channel_array(i,find(channel_array(i,:)~=0));
end
