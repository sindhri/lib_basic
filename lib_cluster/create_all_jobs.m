%20191216, take the project name, which is the same name as the one in the
%main function running MADE. For example, for the project Neurobiology
%father, nf was used as the name, and the main function was called run_nf

%it go through a list of files, either input directly from a cell array, or
%go to a folder.

%it generates a job for each file, then generate a job list, and the
%command to run the job list.

function create_all_jobs(project_name,datafilenames,totalhour,totalram)
%project_name = 'SAS';

if nargin==1
    datafilenames = get_datafilenames;
    totalhour = 5;
    totalram = 8;
end

if nargin==2
    totalhour = 5;
    totalram = 8;
end

if exist('jobs','dir')~=7
    mkdir('jobs');
end

for i = 1:length(datafilenames)
    create_a_job(datafilenames{i},project_name,totalhour,totalram);
end

fid = fopen('jobs/job_list.txt','w');
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

%20191204
%need to update for the project specific path
%the main program to run is called run_MADE_[project_name]
%The program is at
%/ysm-gpfs/home/jw646/project/MADE_pipeline/[project_name]/
%5 hours for ICA

%20200106, changed n of cpu to 4

function create_a_job(datafilename,project_name,totalhour,totalram)
if nargin==2
    totalhour = 5;
    totalram = 8;
end
fid = fopen(['jobs/job_' datafilename '.sh'],'w');
fprintf(fid,'#!/usr/bin/bash\n');
fprintf(fid,'#SBATCH -J %s\n',datafilename);
fprintf(fid,'#SBATCH -n 1\n');

fprintf(fid,['#SBATCH -t ' int2str(totalhour) ':00:00\n']);
fprintf(fid,'#SBATCH -N 1\n');
fprintf(fid,['#SBATCH --mem-per-cpu=' int2str(totalram) 'g\n']); %8G per cpu
fprintf(fid,'#SBATCH -c 4\n'); %4 cpu %when using 1, 5h was not enough to even start ICA on SAS data!
fprintf(fid,'module load MATLAB/2019b\n');
%content = 'matlab -nodisplay -nojvm -nosplash -nodesktop -r ';
content = 'matlab -nodisplay -nosplash -nodesktop -r ';
content = [content '"addpath(''/ysm-gpfs/home/jw646/project/MADE_pipeline/'];
content = [content project_name '/'');run_' project_name];
content = [content '(''' datafilename ''');exit;"\n'];
fprintf(fid,content);
fclose(fid);
end