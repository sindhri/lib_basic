%data, freqs x times x ncond
%report, ncond x rating x ITC/ERSP
%plot all r, ERSP, 
%plot all r, ITC
%plot all p, ERSP
%plot all p, ITC

function IE_post_FDR_images_for_4cond(report)

n_rating = size(report,2);
for i =1:2 %r or p
    if i==1
       rp_name = 'r';       %plot r        
       for m = 1:n_rating
           for j = 1:2 %ITC or ERSP
              report_all_cond = report(:,m,j);
              plot_all_cond_image(report_all_cond,rp_name);
           end
       end
    else
       rp_name = 'p';
       for m = 1:n_rating
           for j = 1:2 %ITC or ERSP
              report_all_cond = report(:,m,j);
              plot_all_cond_image(report_all_cond,rp_name);
           end
       end
    end    
end
end


%report is nx1 struct, n = ncond
function plot_all_cond_image(report,rp_name)

figure;
%h=figure('Units','normalized','Position',[0 0 1 1]);

fontsize = 15;
times = report(1).times;
ncond = size(report,1);
freqs = report.freqs;

data = zeros(size(report(1).r_list,1),size(report(1).r_list,2),ncond);

if rp_name == 'r'
    for i = 1:ncond
        data(:,:,i) = report(i).r_list;
        cond_names{i} = [rp_name ' ' report(i).rating_name ' ' report(i).category_name];
    end
    limit = [min(min(min(data))),max(max(max(data)))];
else
    for i = 1:ncond
        data(:,:,i) = report(i).p_list;
        cond_names{i} = [rp_name ' ' report(i).rating_name ' ' report(i).category_name];
    end
    limit = [0,1];
    bmap(1,:)=[1,0,0];
    bmap(2,:)=[1,0.5,0];
    bmap(3:20,1)=1;
    bmap(3:20,2)=1;
    bmap(3:20,3)=1;
end


offsets = [-0.09,-0.055,-0.02,0.01];


for i = 1:ncond
    h1=subplot(1,ncond,i);
    imagesc(times,freqs,data(:,:,i),limit);
    
    if rp_name == 'p'
        colormap(bmap);
    else
        colormap('default');
    end
    title(cond_names{i},'fontsize',fontsize);
    set(gca,'ydir','normal','fontsize',fontsize,'xtick',0:100:500);
    xlabel('Time(ms)');
    if i==1
        ylabel('Frequency(Hz)');
    end

    colorbar;
    enlarge_plot(h1,offsets(i));
end
figure_name = [report(1).rating_name '_' int2str(report(1).ITC_ERSP_index) rp_name];


h = gcf;

set(h, 'Position', get(0,'Screensize'),'PaperOrientation','landscape'); % Maximize figure. 
%set(h,'PaperUnits','inches','PaperPosition',[5 5 10 8],'PaperOrientation','landscape',...
%    'PaperSize',[10,15]);

%print(h,'-dpdf',figure_name,'-r300');
%print(h,'-dpdf',figure_name);

%close(h);
end

function enlarge_plot(h,xchange)
size = get(h,'position');
size2 = size;
size2(1) = size(1) + xchange;
size2(3) = size(3) * 2;
set(h,'position',size2);
end