%to run it on G03 local computer
%open terminal, under directory of '/Users/MACG03/Desktop/RESEARCH/MOD/projects/cyberball/pipeline_oscillation/'
%which means cd into it.
%cd /Users/MACG03/Desktop/RESEARCH/MOD/projects/cyberball/pipeline_oscillation/
%/Applications/MATLAB_R2012b.app/bin/matlab -nodesktop -nosplash -nodisplay -r oscillation_step2
%20171105, result folder is just _result after data_folder

function oscillation_step2(testmode,filename,project_path,data_folder)
tic
%project_path = '/Users/wu/Desktop/RESEARCH/self_compassion_2016/cluster_SC_oscillation/';

addpath([project_path '/analysis/support/dependencies/eeglab13_6_5b/']);
addpath(genpath([project_path '/analysis/support/dependencies/eeglab13_6_5b/functions/']));
addpath([project_path '/analysis/support/dependencies/eeglab13_6_5b/sample_locs/']);
addpath([project_path '/analysis/support/dependencies/lib_ITC/']);
data_folder = [project_path '/analysis/data/' data_folder];

%category_names = {'favor','not_my_turn','rejection','cue_fair','cue_unfair'};
vbaseline = [-600,-100];

%data_folder = [project_path '/analysis/data/set_cyberball/'];
result_folder = [data_folder(1:length(data_folder)-1) '_result/'];
if isempty(exist(result_folder))
    mkdir(result_folder);
end

EEG = pop_loadset([data_folder filename]);
EEG.group_name = '';
EEG.vbaseline = vbaseline;
freq_limits = [3,30];
id_type = 1;
ITC_calculation_single_file_single_condition(EEG,freq_limits,...
    id_type,testmode, result_folder);

fprintf('\ncompleted testmode = %s, filename is = %s\n',testmode,EEG.filename);
toc
end

