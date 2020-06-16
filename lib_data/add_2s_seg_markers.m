%20200108, add 2s 
function EEG = add_2s_seg_markers(EEG)

%copy EEG event structure for checking (temporary)
% event2 = struct;
% event2 = EEG.event; 

%event markers for story and post-story conditions
tags = {'sE11', 'sE12', 'sE21', 'sE22','sC11', 'sC12',...
    'sC21', 'sC22','pE11', 'pE12', 'pE21', 'pE22','pC11',...
    'pC12', 'pC21', 'pC22'};

n_event = 30; %number of 2s segments to add per condition

for i = 1:length(EEG.event) %iterate through each event in the EEG dataset
    
    for a = 1:length(tags) %iterate through the tag list to search for a match
              
          if strcmp(EEG.event(i).type, tags{a}) %if there is a match...
               initlen = length(EEG.event); 
               
               %for story conditions, add 30 2s segments starting 30 seconds after the story starts
               %for post-story conditions, add 30 2s segments starting at the same time as the post-story event marker
               
               if EEG.event(i).type(1) == 's'
                   extra_latency = 30*EEG.srate ;
               else
                   extra_latency = 0 ;
               end
                            
               for b = 1:(n_event)
                   EEG.event(initlen+b).type = [EEG.event(i).type '_2s']; 
                   EEG.event(initlen+b).latency = EEG.event(i).latency+extra_latency+((b-1)*2*EEG.srate);
                   EEG.event(initlen+b).urevent = initlen+b;                      
               end                   
          end
    end  
end

EEG=eeg_checkset(EEG,'eventconsistency'); %check for consistency and reorder the events chronologically

end