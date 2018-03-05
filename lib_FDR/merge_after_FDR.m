%input report, from an FDR approach, with t_list
%find significant datapoint/timepoint and corresponding channels
%merge find the converging window

function output = merge_after_FDR(report)

sign = 1;
pc = 0.05;

p = report.FDR_adj_p;
chan_list = report.channel_list;
[n_chan,n_dp] = size(p);

output = [];

for i=1:n_chan
        m = 2;
        for j = 1:n_dp
        switch sign 
            case 1 
                if p(i,j)>0 && abs(p(i,j)) < pc
                    output(i,1) = chan_list(i);
                    output(i,m) = totime_nobaseline(j);
                    m = m+1;
                end
            case -1
                if p(i,j)<0 && abs(p(i,j)) < pc
                    output(i,1) = chan_list(i);
                    output(i,m) = totime_nobaseline(j);
                    m = m+1;
                end
        end
    end
end

end

function t = totime_nobaseline(x)
t = x*4;
end