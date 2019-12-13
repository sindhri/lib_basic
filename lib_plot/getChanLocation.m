%2011-08-09, changed folder
%need to make number of channels flexible at some point

%2013-04-15, added net_type as an argument
%1. 129hydrocell
%2. old 129GSN

%20190122, removed G03 dependency to work on jia's mac as well

function location = getChanLocation(net_type)

%pd = strcat('/Users/MacG03/',...
%    'Documents/MATLAB/work/lib_basic/lib_plot/',...
%    'chan_location/');

if nargin==0
    filename = uigetfile('*.loc','choose the channel location file');
else
    switch net_type
        case 1
            filename = 'Hydrocell_Chan129.loc';
        case 2
            filename = 'Chan129.loc';
    end
end

fid=fopen(filename,'r');

nchan=129;
location=zeros(nchan,2);

for i = 1:nchan
    fscanf(fid,'%d',1);
    location(i,1) = fscanf(fid,'%d',1);
    location(i,2) = fscanf(fid,'%f',1);
    fscanf(fid,'%s',1);
end

fclose(fid);