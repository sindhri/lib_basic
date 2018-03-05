%20171108, added rating_name and to_plot,condition_to_correlate,
%to_move_outlier
%20171109, added title to correlation plots
%generalized the story, compare two conditions

%input data structure
%poi
%poi.time = [150,300];
%poi.cluster = [11,12,5,6];
%poi.cluster_name = 'P2';
%poi.method = 'peak_picking'; 
%poi.method = 'averaged_amplitude';
%whether to plot, 1 means to plot
%conditions_to_compare, [cond1, cond2]. the two groups will compare on the
%two conditions
%added peak picking

%compare the same condition across groups
%20171130, added rating as well, combine groups, and do rating with each of
%the conditions
function [data_plot1,data_2d1,data_signature1,...
    data_plot2,data_2d2, data_signature2] = story_groupcompare2_rating(data_ave1,...
    data_ave2,poi,to_plot,conditions_to_compare,rating_struct,rating_name)

if length(conditions_to_compare)~=2
    fprintf('need 2 conditions\n');
    return
end

if strcmp(poi.method,'peak_picking')==1
    [data_2d1,data_signature1] = calc_pickpeaking(data_ave1,poi);
    [data_2d2,data_signature2] = calc_pickpeaking(data_ave2,poi);
else
    [data_2d1,data_signature1] = calc_avgtimechan(data_ave1,poi);
    [data_2d2,data_signature2] = calc_avgtimechan(data_ave2,poi);
end
data_plot1 = mean(data_ave1.data,4);
data_plot1 = squeeze(mean(data_plot1(poi.cluster,:,:),1));
data_plot1 = data_plot1';

data_plot2 = mean(data_ave2.data,4);
data_plot2 = squeeze(mean(data_plot2(poi.cluster,:,:),1));
data_plot2 = data_plot2';


%use first dimension, for amplitude
%use second dimension, for latency
if strcmp(poi.method,'peak_picking')==1
    fprintf('amplitude comparison\n');
end
measure1 = data_signature1.data(:,conditions_to_compare(1),1);
id1 = data_signature1.id;
measure2 = data_signature2.data(:,conditions_to_compare(1),1);
id2 = data_signature2.id;
do_2group_single(measure1,measure2,id1,id2);

measure1 = data_signature1.data(:,conditions_to_compare(2),1);
id1 = data_signature1.id;
measure2 = data_signature2.data(:,conditions_to_compare(2),1);
id2 = data_signature2.id;
do_2group_single(measure1,measure2,id1,id2);

legend_names = data_ave1.category_names(conditions_to_compare);
plot_xmin = data_ave1.xmin*1000;
plot_xmax = data_ave1.xmax*1000;
step = 1000/data_ave1.srate;
if to_plot ==1
    figure;
    subplot(1,2,1);
    plot(plot_xmin:step:plot_xmax,data_plot1(conditions_to_compare(1),:),'k');
    hold on;
    plot(plot_xmin:step:plot_xmax,data_plot1(conditions_to_compare(2),:),'r');
    legend(legend_names);
    title(data_ave1.group_name);
    
   subplot(1,2,2);
    plot(plot_xmin:step:plot_xmax,data_plot2(conditions_to_compare(1),:),'k');
    hold on;
    plot(plot_xmin:step:plot_xmax,data_plot2(conditions_to_compare(2),:),'r');
    legend(legend_names);
    title(data_ave2.group_name);
end

if strcmp(poi.method,'peak_picking')==1
    fprintf('latency comparison\n');
measure1 = data_signature1.data(:,conditions_to_compare(1),2);
id1 = data_signature1.id;
measure2 = data_signature2.data(:,conditions_to_compare(1),2);
id2 = data_signature2.id;
do_2group_single(measure1,measure2,id1,id2);

measure1 = data_signature1.data(:,conditions_to_compare(2),2);
id1 = data_signature1.id;
measure2 = data_signature2.data(:,conditions_to_compare(2),2);
id2 = data_signature2.id;
do_2group_single(measure1,measure2,id1,id2);
end

%do ratings
data_ave = ITC_combine_ave(data_ave1,data_ave2);
[data_2d1,data_signature1] = calc_avgtimechan(data_ave,poi);

measure1 = data_signature1.data(:,conditions_to_compare(1),1);
id1 = data_signature1.id;
measure2 = rating_struct.(rating_name);
id2 = rating_struct.id;
do_coorcoef_single(measure1,measure2,id1,id2,1,rating_name);

measure1 = data_signature1.data(:,conditions_to_compare(2),1);
id1 = data_signature1.id;
measure2 = rating_struct.(rating_name);
id2 = rating_struct.id;
do_coorcoef_single(measure1,measure2,id1,id2,1,rating_name);
end