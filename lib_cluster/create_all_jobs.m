%20191204
%need to update for individual project
%then it generates a folder jobs. Move it to where the project folder is

project_name = 'SAS';

datafilenames = get_datafilenames;

if exist('jobs','dir')~=7
    mkdir('jobs');
end

for i = 1:length(datafilenames)
    create_a_job(datafilenames{i},project_name);
end

fid = fopen('jobs/job_list.txt','a');
for i = 1:length(datafilenames)
    content = 'sbatch /ysm-gpfs/home/jw646/project/MADE_pipeline/';
    content = [content project_name '/jobs/job_' datafilenames{i} '.sh\n'];
    fprintf(fid,content);
end
fclose(fid);

fid = fopen('jobs/run_command.txt','w');
fprintf(fid,'module load dSQ\n');
content2 = 'dSQ.py --submit --jobfile /ysm-gpfs/home/jw646/project/';
content2 = [content2 'MADE_pipeline/' project_name '/jobs/job_list.txt'];
fprintf(fid,content2);
fclose(fid);
