%20191216, take the project name, which is the same name as the one in the
%main function running MADE. For example, for the project Neurobiology
%father, nf was used as the name, and the main function was called run_nf

%it go through a list of files, either input directly from a cell array, or
%go to a folder.

%it generates a job for each file, then generate a job list, and the
%command to run the job list.

function create_all_jobs(project_name,datafilenames)
%project_name = 'SAS';

if nargin==1
    datafilenames = get_datafilenames;
end

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
end