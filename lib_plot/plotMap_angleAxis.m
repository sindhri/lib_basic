%7 colors %multiple shapes
%present 1 measurement on a plot
%present 1 or more condition on a plot
%update 2/7/2011
%2011-09-12, fixed baseline issue

function plotMap_angleAxis(p_matrix,criterion)

%legend_labels = {'diff','failToAvoid','avoid'};
baseline = 100;

position_in_range = getChanLocation;

if nargin ==1
   criterion = 0.05;
end

[channel,datapoint,condition]=size(p_matrix);

if channel~=size(position_in_range,1)
    fprintf('channel number mismatch!\n');
    return
end

data_length = datapoint*4;
color_lab = 'rbgcmyk';
shape_lab = '.ox+*sdv^<>ph';


figure;

for i = 1:channel
    subplot('position',[(position_in_range(i,2)*sin(position_in_range(i,1)/180*3.1416)+0.55)*0.9,(position_in_range(i,2)*cos(position_in_range(i,1)/180*3.1416)+0.55)*0.9,0.03,0.03]);
    if nargin > 0
       for c = 1:condition
           plot(0-baseline:4:data_length-4-baseline,p_matrix(i,:,c),[color_lab(rem(c,length(color_lab))) shape_lab(floor(c/length(color_lab))+1)'.']);
           h = gca;
           set(h,'fontsize',1);
           hold on;
       end
    end
    %xlabel('Time(ms)');
    %ylabel('p value with sign');
    axis([0-baseline,data_length-baseline,-criterion,criterion]);
    h = title(int2str(i));
    set(h,'fontsize', 10,'fontweight','bold','fontname','arial');
end

set(gcf,'color','w');
hold off;
axcopy; 
  