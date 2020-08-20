restoredefaultpath;
addpath(genpath('/Users/wu/Documents/MATLAB/work/lib_basic/'));
addpath('/Users/wu/Documents/MATLAB/work/toolbox/eeglab14_0_0b/');
addpath('/Users/wu/Documents/MATLAB/work/toolbox/eeglab14_0_0b/sample_locs');
addpath(genpath('/Users/wu/Documents/MATLAB/work/toolbox/eeglab14_0_0b/functions'));

eventtypes = {'lose','win'};
baseline = 600;
group_name = '';
ID_type = 1;
net_type = 1;

bart_raw = ITC_read_egi(eventtypes,baseline,...
    group_name,ID_type,net_type);

freq_limits = [3.5,30];
vbaseline = [-100,0];

%frontal1
chan_list.channel = [11 12 5 6];
chan_list.name = 'frontal1';
bart_oscillation_f1 = ITC_calculation_vbaseline(bart_raw, ...
    chan_list,freq_limits,vbaseline);

ITC_images_for_2cond(bart_oscillation_f1);

frontal1_poi_ERSP = [4,7,100,300;...
    4,7,400,500];
frontal1_poi_ITC = [4,7,100,400];
frontal1_doi_ERSP = ITC_create_doi(bart_oscillation_f1,...
    frontal1_poi_ERSP, 'ERSP', 'n');
frontal1_doi_ITC = ITC_create_doi(bart_oscillation_f1,...
    frontal1_poi_ITC, 'ITC', 'n');
doi_frontal1 = ITC_combine_doi_addcol(frontal1_doi_ERSP, frontal1_doi_ITC);


%posterior1
chan_list.channel = [62 72 67 77];
chan_list.name = 'posterior1';
bart_oscillation_p1 = ITC_calculation_vbaseline(bart_raw, ...
    chan_list,freq_limits,vbaseline);
save bart_oscillation_p1 bart_oscillation_p1;
ITC_images_for_2cond(bart_oscillation_p1);

posterior1_poi_ERSP = [4,7,100,300;...
    4,7,400,500];
posterior1_poi_ITC = [4,7,100,400];

posterior1_doi_ERSP = ITC_create_doi(bart_oscillation_p1,...
    posterior1_poi_ERSP, 'ERSP', 'n');
posterior1_doi_ITC = ITC_create_doi(bart_oscillation_p1,...
    posterior1_poi_ITC, 'ITC', 'n');
doi_posterior1 = ITC_combine_doi_addcol(posterior1_doi_ERSP, posterior1_doi_ITC);

doi1 = ITC_combine_doi_addcol(doi_frontal1, doi_posterior1);


%frontal2
chan_list.channel = [17 21 14 15 22 9 16 18 10];
chan_list.name = 'frontal2';
bart_oscillation_f2 = ITC_calculation_vbaseline(bart_raw, ...
    chan_list,freq_limits,vbaseline);
save bart_oscillation_f2 bart_oscillation_f2;
ITC_images_for_2cond(bart_oscillation_f2);

frontal2_poi_ERSP = [4,7,100,300;...
    4,7,400,500];
frontal2_poi_ITC = [4,7,100,400];
frontal2_doi_ERSP = ITC_create_doi(bart_oscillation_f2,...
    frontal2_poi_ERSP, 'ERSP', 'n');
frontal2_doi_ITC = ITC_create_doi(bart_oscillation_f2,...
    frontal2_poi_ITC, 'ITC', 'n');
doi_frontal2 = ITC_combine_doi_addcol(frontal2_doi_ERSP, frontal2_doi_ITC);



%posterior2
chan_list.channel = [75 74 81 82];
chan_list.name = 'posterior2';
bart_oscillation_p2 = ITC_calculation_vbaseline(bart_raw, ...
    chan_list,freq_limits,vbaseline);
save bart_oscillation_p2 bart_oscillation_p2;
ITC_images_for_2cond(bart_oscillation_p2);

posterior2_poi_ERSP = [4,7,100,300;...
    4,7,400,500];
posterior2_poi_ITC = [4,7,100,400];

posterior2_doi_ERSP = ITC_create_doi(bart_oscillation_p2,...
    posterior2_poi_ERSP, 'ERSP', 'n');
posterior2_doi_ITC = ITC_create_doi(bart_oscillation_p2,...
    posterior2_poi_ITC, 'ITC', 'n');
doi_posterior2 = ITC_combine_doi_addcol(posterior2_doi_ERSP, posterior2_doi_ITC);

doi2 = ITC_combine_doi_addcol(doi_frontal2, doi_posterior2);
doi = ITC_combine_doi_addcol(doi1, doi2);
