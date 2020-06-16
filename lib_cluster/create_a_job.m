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