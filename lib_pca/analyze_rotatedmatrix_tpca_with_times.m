%input rotated matrix data
%it can be copy and paste to become a matlab variable
%it can also be saved as a rft and then read by readRotatedMatrix.m
%numberOfFactor has to be no more than 7
%factorVariance will be 7, size deducted after the program
%9/17/2009, able to choose specific factors, use selected_factors, such as
%[2,3]
%non-overlap needs work

%when nothing is over 0.4, need work, 2/2/2011
%changed criterial to 0.4 to enable automation, 03/10/2011

%2011-08-08
%removed the factors that do not have anything over threshold

%2011-08-22
%used the whole FactorResult, so that variance information is available
%added function to write the factor info out.

%2011-09-07
%fixed bug for 1 factor

%2011-09-09
%fixed bug for always omitting the last factor

%20121003
%added times variable, so that it doesn't have to be 250Hz
%times variable is like [-100,-96,.....0,4,8,...]
%pca data always starts from the time that is after times==0

%20130128
%changed pca start time from 0 to arbitary

function [factor_time,factor_time_peak,filename,...
    factor_index_in_times] = analyze_rotatedmatrix_tpca_with_times(factorResults,times,threshold)

if nargin==2
    threshold = 0.4;
end
length_threshold = 0;

data = factorResults.FacPat;
time_zero = find(times==0)-1;


nfactor = size(data,2);

%using threshold to determine the boundary of factors
factor_time = zeros(nfactor,2);
factor_index_in_times = zeros(nfactor,2);
factor_time_peak = zeros(nfactor,1);

for i = 1:nfactor
    temp = find(data(:,i) > threshold);
    if ~isempty(temp)
        temp = testContinuity(temp,length_threshold);
        factor_index_in_times(i,1) = time_zero+temp(1);
        factor_index_in_times(i,2) = time_zero+temp(length(temp));
        factor_time(i,1) = times(factor_index_in_times(i,1));
        factor_time(i,2) = times(factor_index_in_times(i,2));
        factor_time_peak(i) =times(time_zero+find(data(:,i) == max(data(:,i)),1));
    end
end
filename = ['factor_info_tpca_' int2str(nfactor) 'f.txt'];
write_tpca_result(factorResults, factor_time, factor_time_peak,...
    threshold,filename);
end

function write_tpca_result(factorResults, factor_time, ...
    factor_time_peak, threshold, filename)

nfactor = size(factor_time,1);
factor_variance = factorResults.facVar(1:nfactor);


fid = fopen(filename,'w');
fprintf(fid,'tpca threshold %.1f, n = %d \n',threshold,nfactor);

for i=1:nfactor
    fprintf(fid,'Factor %d Variance: %2.2f%%\t',i,factor_variance(i)*100);
    fprintf(fid,'Time Interval: %d - %d ms\t', factor_time(i,1),factor_time(i,2));
    fprintf(fid,'Peak Time: %dms\n', factor_time_peak(i));
end

questdlg(['factor information is recorded in file ' filename],'','OK','OK');

fclose(fid);
end