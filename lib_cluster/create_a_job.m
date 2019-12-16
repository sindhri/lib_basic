%20191204
%need to update for the project specific path
%the main program to run is called run_MADE_[project_name]
%The program is at
%/ysm-gpfs/home/jw646/project/MADE_pipeline/[project_name]/
%5 hours for ICA

function create_a_job(datafilename,project_name)
fid = fopen(['jobs/job_' datafilename '.sh'],'w');
fprintf(fid,'#!/usr/bin/bash\n');
fprintf(fid,'#SBATCH -J %s\n',datafilename);
fprintf(fid,'#SBATCH -n 1\n');

fprintf(fid,'#SBATCH -t 05:00:00\n');
fprintf(fid,'#SBATCH -N 1\n');
fprintf(fid,'#SBATCH --mem-per-cpu=8g\n'); %8G per cpu
fprintf(fid,'#SBATCH -c 4\n'); %4 cpu
fprintf(fid,'module load MATLAB/2019b\n');
%content = 'matlab -nodisplay -nojvm -nosplash -nodesktop -r ';
content = 'matlab -nodisplay -nosplash -nodesktop -r ';
content = [content '"addpath(''/ysm-gpfs/home/jw646/project/MADE_pipeline/'];
content = [content project_name '/'');run_' project_name];
content = [content '(''' datafilename ''');exit;"\n'];
fprintf(fid,content);
fclose(fid);
end