%20200812
%foi_ERSP comes after recompose of the fullhead oscillation data
%then had to manually add id to it. 
%need to fix the problem so id is included during recomposition

%convert foi_ERSP which is an array of structure
%to EEGAVE, which is one structure with all the information combined

%foi_ERSP(1) data: nchan x ntime x nsubj
%in EEGAVE, need to convert to nchan x ntime x ncond x nsubj

%input type = 1, EEGAVE data: nchan x ntime x nsubj x ncond, for
%FH_cal_all_cor
%input type = 2, EEGAVE data: nchan x ntime x ncond x nsubj, for
%FH_cal_all_cor_2

function EEGAVE = FH_convert_foi_ERSP_to_fake_EEGAVE(foi_ERSP, type)

data = zeros(size(foi_ERSP(1).data));
eventtypes = cell(1);

if type == 2
    for i = 1:length(foi_ERSP) %ncond
        for j = 1:size(foi_ERSP(1).data,3) %nsubj
            data(:,:,i,j) = foi_ERSP(i).data(:,:,j);
        end
        eventtypes{i} = foi_ERSP(i).setname;
    end
else
    for i = 1:length(foi_ERSP)
        data(:,:,:,i) = foi_ERSP(i).data;
        eventtypes{i} = foi_ERSP(i).setname;
    end
end
EEGAVE.ID = str2double(foi_ERSP(1).id);
EEGAVE.data = data;
EEGAVE.eventtypes = eventtypes;
EEGAVE.nbchan = foi_ERSP(1).nbchan;
EEGAVE.pnts = foi_ERSP(1).pnts;
EEGAVE.srate = 1000/(foi_ERSP(1).times(2) - foi_ERSP(1).times(1));
EEGAVE.xmin = foi_ERSP(1).xmin;
EEGAVE.xmax = foi_ERSP(1).xmax;
EEGAVE.times = foi_ERSP(1).times;
EEGAVE.chanlocs = foi_ERSP(1).chanlocs;

end
