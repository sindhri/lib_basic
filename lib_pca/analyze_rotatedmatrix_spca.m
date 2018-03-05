%input FactorResult from pca
%output the index of data that is over the threshold
%2011-08-08, input the factors you want to look at
%such as [11:20]

%2014-07-01, added net type

function clusters = analyze_rotatedmatrix_spca(FactorResult, ...
    threshold, factors, net_type)

if nargin==3
    net_type = 1;
end

rm = FactorResult.FacPatST;
vr = FactorResult.facVarST;

m=1;
for i=factors
    
    clusters{1,m}.factor = i;
    clusters{1,m}.variance = vr(i);
    clusters{1,m}.threshold = ['>' num2str(threshold)];
    clusters{1,m}.channel = find(rm(:,i)>threshold);
    
    clusters{2,m}.factor = i;
    clusters{2,m}.variance = vr(i);
    clusters{2,m}.threshold = ['<-' num2str(threshold)];
    clusters{2,m}.channel = find(rm(:,i)<-threshold);
    
    figure;
    plot_2clusters(clusters{1,m}.channel, clusters{2,m}.channel,net_type);
    fprintf(['factor ' num2str(i) ' variance ' num2str(vr(i)) '\n']);
    m = m+1;
end

