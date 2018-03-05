%20170810, plot significant channels from FDR report
%using report.p_sign, red-positive t/r, blue-negative t/r
function plot_significant_channels_from_report(report,net_type)

    sig_channels_pos = find(report.p_sign > 0 & report.p_sign < 0.05);
    sig_channels_neg = find(report.p_sign < 0 & report.p_sign > -0.05);
    plot_significant_channels_by_sign(sig_channels_pos,sig_channels_neg,net_type);

end