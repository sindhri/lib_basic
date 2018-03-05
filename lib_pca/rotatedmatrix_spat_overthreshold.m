%input FactorResult from pca
%output the index of data that is over the threshold

function clusters = rotatedmatrix_spat_overthreshold(FactorResult, threshold)

rm = FactorResult.FacPat;
vr = FactorResult.facVar;
[~, nfactor] = size(rm);

for i=1:nfactor
    
    clusters{i*2-1}.factor = i;
    clusters{i*2-1}.variance = vr(i);
    clusters{i*2-1}.threshold = ['>' num2str(threshold)];
    clusters{i*2-1}.channel = find(rm(:,i)>threshold);
    
    clusters{i*2}.factor = i;
    clusters{i*2-1}.variance = vr(i);
    clusters{i*2}.threshold = ['<-' num2str(threshold)];
    clusters{i*2}.channel = find(rm(:,i)<-threshold);
    
    figure;
    plot_2clusters(clusters{i*2-1}.channel, clusters{i*2}.channel);
    fprintf(['factor ' num2str(i) ' variance ' num2str(vr(i)) '\n']);
end

