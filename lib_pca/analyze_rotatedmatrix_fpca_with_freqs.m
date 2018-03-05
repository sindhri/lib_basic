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

%implemented frequency domain

function [factor_freq,factor_freq_peak,...
    factor_index_in_freqs] = analyze_rotatedmatrix_fpca_with_freqs(factorResults,freqs,filename_to_append,threshold)

if nargin==3
    threshold = 0.8;
end
length_threshold = 0;

data = factorResults.FacPatST;

nfactor = size(data,2);

%using threshold to determine the boundary of factors
factor_freq = zeros(nfactor,2);
factor_index_in_freqs = zeros(nfactor,2);
factor_freq_peak = zeros(nfactor,1);
     
for i = 1:nfactor
    temp = find(data(:,i) > threshold);
    if ~isempty(temp)
       temp = testContinuity(temp,length_threshold); 
       factor_index_in_freqs(i,1) = temp(1);
       factor_index_in_freqs(i,2) = temp(length(temp));
       factor_freq(i,1) = freqs(factor_index_in_freqs(i,1));       
       factor_freq(i,2) = freqs(factor_index_in_freqs(i,2));
       factor_freq_peak(i) =freqs(find(data(:,i) == max(data(:,i)),1));
    end
end

write_fpca_result(factorResults, factor_freq, factor_freq_peak,...
    threshold,filename_to_append);
end

function write_fpca_result(factorResults, factor_freq, ...
    factor_freq_peak, threshold,filename_to_append)

nfactor = size(factor_freq,1);
factor_variance = factorResults.facVarST(1:nfactor);

fid = fopen(filename_to_append,'a');
fprintf(fid,'\nfpca threshold %.1f, n = %d\n',threshold,nfactor);

for i=1:nfactor
    fprintf(fid,'Factor %d Variance: %2.2f%%\t',i,factor_variance(i)*100);
    fprintf(fid,'Frequency Interval: %.2f - %.2f Hz\t', factor_freq(i,1),factor_freq(i,2));
    fprintf(fid,'Peak Frequency: %.2f Hz\n', factor_freq_peak(i));
end


fclose(fid);
end