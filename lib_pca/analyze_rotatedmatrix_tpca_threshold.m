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

function [factor_time,factor_time_peak, ...
    factor_determine_type] = analyze_rotatedmatrix_tpca_threshold(factorResults,...
    threshold,sampling_rate)

data = factorResults.FacPat;

if length(size(data)) ~=2
    fprintf('the input rotated matrix should be 2 dimensional\n');
    return
end

if nargin==1
    threshold = 0.4;
end
if nargin<3
    sampling_rate = 250;
end

dps = floor(1000/sampling_rate);

%length_threshold = 10; %at least 4 x 10 = 12 ms long
length_threshold = 0;

[datapoint, nfactor] = size(data);
selected_factors = 1:nfactor;

%using threshold to determine the boundary of factors

factor_determine_type = questdlg('what is the criterial?','',...
    '1. threshold = 0.4','2. non-overlap','3. manual','1. threshold = 0.4');

%factor_determine_type = '1. threshold = 0.4';
criterial = str2num(factor_determine_type(1));

switch criterial
    case 1
        found_empty = 0;
        for i=1:nfactor
            if isempty(find(data(:,i)>threshold))
                msgbox(['original ' int2str(nfactor) ' factors, found ' int2str(i-1) ' factors']);
                found_empty = 1;
                break
            end
        end
       
        if found_empty == 1
            selected_factors = 1:i-1;
        else
            selected_factors = 1:i;
        end

        m = 1;
        for i = selected_factors
            temp = find(data(:,i) > threshold);
            temp = testContinuity(temp,length_threshold);     
            factor_time(m,:) = [temp(1)*dps,temp(length(temp))*dps];
            %factor_time_peak(m) = max(temp)*4; %mistaken
            factor_time_peak(m) = find(data(:,i) == max(data(:,i)),1)*dps;
            m = m+1;
            if m > max(selected_factors)
                break
            end
        end
    case 2
        data = data(:,1:max(selected_factors));
            for i = 1:datapoint
                    %the following matrix will present the largest factor for each
                    %datapoint
                if ~isempty(find(data(i,:)>threshold))
                    factorAtTheMoment(i) = find(data(i,:) == max(data(i,:)),1);
                end
            end 
            for i = 1:max(selected_factors)
                temp = find(factorAtTheMoment==i);
                temp = testContinuity(temp,length_threshold);
                factor_time(i,1) = min(temp)*dps;
                factor_time(i,2) = max(temp)*dps;
                temp2 = find(data(:,i)==max(data(:,i)));
                factor_time_peak(i) = temp2(floor(length(temp2)/2)+1)*dps;
            end
    case 3
        temp = inputdlg({'f1 start time','f1 stop time','f1 peak time',...
            'f2 start time','f2 stop time','f2 peak time',...
            'f3 start time','f3 stop time','f3 peak time',...
            'f4 start time','f4 stop time','f4 peak time',...
            'f5 start time','f5 stop time','f5 peak time',...
            'f6 start time','f6 stop time','f6 peak time'},'integer only',1);
        
        for i = selected_factors
            factor_time(i,1) = str2num(temp{(i-1)*3+1});
            factor_time(i,2) = str2num(temp{(i-1)*3+2});
            factor_time_peak(i) = str2num(temp{(i-1)*3+3});
        end
    otherwise
        fprintf('case not set up!');
end

write_tpca_result(factorResults, factor_time, factor_time_peak,...
    factor_determine_type);
end

function write_tpca_result(factorResults, factor_time, ...
    factor_time_peak, factor_determine_type)

nfactor = size(factor_time,1);
factor_variance = factorResults.facVar(1:nfactor);

fid = fopen(['factor_info_tpca_' int2str(nfactor) 'f.txt'],'w');
for i=1:nfactor
    fprintf(fid,'Factor %d Variance: %2.2f%%\t',i,factor_variance(i)*100);
    fprintf(fid,'Time Interval: %d - %d ms\t', factor_time(i,1),factor_time(i,2));
    fprintf(fid,'Peak Time: %dms\n', factor_time_peak(i));
end

fprintf(fid,'\nfactors are determined by %s\n',factor_determine_type);

questdlg(['factor information is recorded in file ''factor_info_tpca_' int2str(nfactor) 'f.txt'''],'','OK','OK');

fclose(fid);
end