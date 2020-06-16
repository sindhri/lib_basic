%20200208, added option of not printing the results
%20191116, input a group variable, and repeated measures for running
%repeated measures ANOVA
function [ranovatbl,F,p,df] = FH_cal_rm(group,measures,print_result)
if nargin==2
    print_result = 1;
end

if istable(group) && istable(measures)
    t = [group,measures];
    t.Properties.VariableNames = {'group' 'meas1' 'meas2'};
else
     t = table(group,measures(:,1),measures(:,2),...
     'VariableNames',{'group','meas1','meas2'});
end
      Measure_index = table([1 2]','VariableNames',{'Measurements'});
      Measure_index.Measurements = categorical(Measure_index.Measurements);
      t.group = categorical(t.group);
      rm = fitrm(t,'meas1-meas2~group','WithinDesign',Measure_index);
      ranovatbl = ranova(rm,'WithinModel','Measurements');
      %measure-- within variable
      F(1,1) = ranovatbl.F(4);
      p(1,1) = ranovatbl.pValueGG(4);
      df{1,1} = [ranovatbl.DF(4),ranovatbl.DF(6)];
      %interaction
      F(1,2) = ranovatbl.F(5);
      p(1,2) = ranovatbl.pValueGG(5);
      df{1,2} = [ranovatbl.DF(5),ranovatbl.DF(6)];
      %between
      F(1,3) = ranovatbl.F(2);
      p(1,3) = ranovatbl.pValueGG(2);
      df{1,3} = [ranovatbl.DF(2),ranovatbl.DF(3)];

      if print_result == 1
            %fprintf('Repeated Measures ANOVA results:\n');
            fprintf('Measure: \nF(%d,%d) = %.2f, ',...
                df{1,1}(1),df{1,1}(2),F(1,1));
            fprintf('p = %.3f\n',p(1,1));
            
            fprintf('Measure * Group: \nF(%d,%d) = %.2f, ',...
                df{1,2}(1),df{1,2}(2),F(1,2));
            fprintf('p = %.3f\n',p(1,2));

            fprintf('Group effect: \nF(%d,%d) = %.2f, ',...
                 df{1,3}(1),df{1,3}(2),F(1,3));
            fprintf('p = %.3f\n',p(1,3));
       end
end