%modified channel_pairs to channel_names

function TS_coh_plot(all_coh,timesout,freqsout,id_list,channel_names)

[nsubject,n_channelpair,~] = size(all_coh);

if nargin==2
    id_list=[];
end

freq_want = [8,12];
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

    legend('nogo','go','nogo-go');
    text(x_max* 1.5,0,channel_pair_names);
    hold off;
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
    title(['Grand Average ' channel_pair_names]);
    hold on;
end
legend('nogo','go','nogo-go');
hold off;
