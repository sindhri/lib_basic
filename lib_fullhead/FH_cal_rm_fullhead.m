%based on FH_cal_rm
%can only work with 1 within variable
%and 1 between variable

%data1, nchan x ndpt x 1cond x nsubj
%data2, nchan x ndpt x 1cond x nsubj
%between_var, array of the group variable

function [within,interaction,between,...
    rmtable] = FH_cal_rm_fullhead(data1,data2,between_var)
    
    [nchan,ndpt,~] = size(data1);

    for m = 1:nchan
        fprintf('\nchan %d dpt ',m);
        for n = 1:ndpt
            if mod(n,ndpt/10)==0
                fprintf('%d ',n);
            end
            cdata1 = squeeze(data1(m,n,:));
            cdata2 = squeeze(data2(m,n,:));
            measures = [cdata1,cdata2];
            [ranovatbl,F,p,df] = FH_cal_rm(between_var,measures,0);

            within.F(m,n) = F(1,1);
            within.p(m,n)= p(1,1);
            within.df{m,n} = df{1,1};
            interaction.F(m,n) = F(1,2);
            interaction.p(m,n)= p(1,2);
            interaction.df{m,n} = df{1,2};
            between.F(m,n) = F(1,3);
            between.p(m,n) = p(1,3);
            between.df{m,n} = df{1,3};
            rmtable{m,n} = ranovatbl;
        end
    end
end