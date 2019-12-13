function [x,y] = coh_getxy_from_chanlocs(chanlocs,num)

    Th = chanlocs(num).theta;
    Th = pi/180*(90-Th);
    Rd = chanlocs(num).radius;
    [x,y] = pol2cart(Th,Rd);
end