%more note. note even correct. should follow what's in FH_cal_rm
%20200208, separated it out frmo FH_cal_all_rm1_2, but useless
%can only work with 1 within variable
%and 1 between variable

%data1, nchan x ndpt x 1cond x nsubj
%data2, nchan x ndpt x 1cond x nsubj
%between_var, array of the group variable
function [within,between] = FH_get_rm(data1,data2,between_var)
    
    [nchan,ndpt,~] = size(data1);

    for m = 1:nchan
        fprintf('\nchan %d dpt ',m);
        for n = 1:ndpt
            if mod(n,ndpt/10)==0
                fprintf('%d ',n);
            end
            cdata1 = squeeze(data1(m,n,:));
            cdata2 = squeeze(data2(m,n,:));
            t = table(between_var,cdata1,cdata2,...
            'VariableNames',{'group','meas1','meas2'});
            Meas = table([1 2]','VariableNames',{'Measurements'});
            rm2 = fitrm(t,'meas1-meas2~group','WithinDesign',Meas);
            [ranovatbl] = ranova(rm2);
                 anovatbl = anova(rm2);
                 %validated with SPSS 26, the effect for the within factor
                 %is slightly different, rest of the factors have the exact
                 %number

            within.F(m,n) = ranovatbl.F(2);
            within.p(m,n)= ranovatbl.pValueGG(2);
            within.df{m,n} = ranovatbl.DF(2:3);
            between.F(m,n) = anovatbl.F(2);
            between.p(m,n) = anovatbl.pValue(2);
            between.df{m,n} = anovatbl.DF(2:3);
            
        end
    end
end