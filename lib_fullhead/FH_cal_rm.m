%20191116, input a group variable, and repeated measures for running
%repeated measures ANOVA
function ranovatbl = FH_cal_rm(group,measures)
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
            
            %fprintf('Repeated Measures ANOVA results:\n');
            fprintf('Measure: \nF(%d,%d) = %.2f, ',...
                ranovatbl.DF(4),ranovatbl.DF(6),ranovatbl.F(4));
            fprintf('p = %.3f\n',ranovatbl.pValueGG(4));
            
            fprintf('Measure * Group: \nF(%d,%d) = %.2f, ',...
                ranovatbl.DF(5),ranovatbl.DF(6),ranovatbl.F(5));
            fprintf('p = %.3f\n',ranovatbl.pValueGG(5));

            fprintf('Group effect: \nF(%d,%d) = %.2f, ',...
                ranovatbl.DF(2),ranovatbl.DF(3),ranovatbl.F(2));
            fprintf('p = %.3f\n',ranovatbl.pValueGG(2));
end