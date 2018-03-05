function factor_datapoint = convert_time2datapoint(factor_time, baseline)

if nargin == 1
    baseline = 100;
end

factor_datapoint = (factor_time + baseline)/4;
