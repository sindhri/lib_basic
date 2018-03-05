stpca procedure

1. decide the number of factors for tpca and spca
data_4d should be chan x datapoint x cond x subject
then run 

[FactorResults_tpca, ...
    FactorResults_stpca] = stPCA_procedure_data_4d_modified(data_4d, ...
    n_tpca, n_spca,condition_selected);

2. based on scree plot and eigen value and variance to decide the number of factors to keep. then run the above command again with the updated number of factors

3. get the factor time for tpca and clusters for stpca, run
[clusters,factor_time] = post_stpca_get_params(FactorResults_tpca, FactorResults_stpca,n_tpca,n_spca);

4. then based on the number of channels in each cluster/polarity, decide which factor to analyze, run
