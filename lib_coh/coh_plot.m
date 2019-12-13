%modified channel_pairs to channel_names
%update using struction on 20150602
%20150616, added output nogo_go as the difference, so that it could be used
%to make grant plots

function nogo_go = coh_plot(COH,freq_want)

all_coh = COH.data;
timesout = COH.times;
freqsout = COH.freqs;
id_list = COH.id;
channel_names = COH.montage_name;
title_freq = [int2str(freq_want(1)) 'to' int2str(freq_want(2)) 'Hz'];

[nsubject,n_channelpair,~] = size(all_coh);

%freq_want = [8,12];
freq_datapoint_start=find(freqsout>freq_want(1),1);
freq_datapoint_end=find(freqsout>freq_want(2),1)-1;
freq_datapoint = freq_datapoint_start:freq_datapoint_end;


ncol = ceil(sqrt(nsubject));
nrow = ceil(nsubject/ncol);

nogo=zeros(length(timesout),nsubject,n_channelpair);
go=zeros(length(timesout),nsubject,n_channelpair);
nogo_go=zeros(length(timesout),nsubject,n_channelpair);

x = timesout;
x_min = round(timesout(1)/100)*100;
x_max = round(timesout(length(timesout))/100)*100;

for j = 1:n_channelpair
    channel_pair_names = channel_names{j};
    
    figure;

    for i = 1:nsubject

        nogo_temp = all_coh{i,j,1};
        go_temp = all_coh{i,j,2};
        nogo_go_temp = all_coh{i,j,3};
        nogo(:,i,j) = mean(nogo_temp(freq_datapoint,:),1)';
        go(:,i,j) = mean(go_temp(freq_datapoint,:),1)';
        nogo_go(:,i,j) = mean(nogo_go_temp(freq_datapoint,:),1)';

        subplot(nrow,ncol,i);
        plot(x,nogo(:,i,j),'r',x,go(:,i,j),'g',x,nogo_go(:,i,j),'k');
        xlim([x_min,x_max]);
        ylim([-0.5,1]);
        if isempty(id_list)
            title(int2str(i));
        else
            title(id_list{i});
        end
        hold on;
    end
    titlename = [COH.group_name ' ' channel_pair_names ' ' title_freq];
    t=suptitle(titlename);
    set(t,'interpreter','none');

    mylegend=legend('nogo','go','nogo-go');
    legend_position=get(mylegend,'Position');
    legend_position(1)=legend_position(1)+0.2;
    set(mylegend,'Position',legend_position);
%    text(x_max* 1.5,0,channel_pair_names);
    hold off;

    set(gcf, 'PaperPosition', [0 0 18 10]); %Position plot at left hand corner with width 5 and height 5.
    set(gcf, 'PaperSize', [18 10]); 
    saveas(gcf,['plot_coh/' titlename],'pdf');
    close;

end

figure;

ncol=2;
nrow=2;

for i = 1:n_channelpair
    channel_pair_names = channel_names{j};
    
    nogo_temp = mean(nogo(:,:,i),2);
    go_temp = mean(go(:,:,i),2);
    nogo_go_temp = mean(nogo_go(:,:,i),2);
    
    subplot(ncol,nrow,i);
    plot(x,nogo_temp,'r',x,go_temp,'g',x,nogo_go_temp,'k');
    xlim([x_min,x_max]);
    ylim([-0.5,1]);
    t=title(['Grand ' channel_pair_names]);
    set(t,'interpreter','none');
    hold on;
end
titlename=[COH.group_name ' Grand ' title_freq];
t=suptitle(titlename);
set(t,'interpreter','none');
mylegend=legend('nogo','go','nogo-go');
legend_position=get(mylegend,'Position');
legend_position(1)=legend_position(1)+0.13;
set(mylegend,'Position',legend_position);

hold off;

set(gcf, 'PaperPosition', [0 0 18 10]); %Position plot at left hand corner with width 5 and height 5.
set(gcf, 'PaperSize', [18 10]); 
saveas(gcf,['plot_coh/' titlename],'pdf');
close;
