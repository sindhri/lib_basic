%20190922, plot all coherence on the head for a certain frequency
% reference montage = coh_get_channel_pair_names2(channels)

%input coh_ave_grand, which is 5x41 for SPR data, nfreqs x npairs

function coh_plot_fullhead_correlation(coh_ave_grand,channel_clusters,critical_value,filename)

   [nfreqs,npairs] = size(coh_ave_grand);
   keySet = [22, 9, 33, 24, 124,...
        122, 45, 36, 104, 108,...
        58, 52, 92, 96, 70,...
        83];
%valueSet = {'Fp1','Fp2','F7','F3','F4',...
%    'F8','T3','C3','C4','T4',...
%    'P5','P3','P4','T6','O1',...
%    'O2'};
%   channel_name_mapping = containers.Map(keySet,valueSet);
   chanlocs = pop_readlocs('GSN-HydroCel-129minus3_1020names.sfp');
   res = get(0,'screensize');
   f = figure;
   set(f,'position',[0,0,res(3),res(4)/3]);
   
   for i = 1:nfreqs
        subplot(1,nfreqs,i);
        topoplot([],chanlocs,'plotchans',keySet,'electrodes','ptslabels',...
            'emarker',{'o','k',32,1},'headrad',0.5);
       for j = 1:npairs
           coh = coh_ave_grand(i,j);
           pair = channel_clusters{j};
           num1 = pair(1);
           num1 = num1{1};
           num2 = pair(2);
           num2 = num2{1};
           coh_drawcoh_between_two_locations_correlation(chanlocs,num1,num2,...
               coh,critical_value);
           %0.10 critical r value 0.138
            %0.05 critical r value 0.164
            %0.01 critical r value 0.215
       end
   end
   set(gcf,'Position',[0 0 res(3) res(4)/3]);
        
   if ~exist('plot_fullhead/','dir')
      mkdir('plot_fullhead');
   end
   saveas(gcf,['plot_fullhead/' filename '.png']);
   close;
end