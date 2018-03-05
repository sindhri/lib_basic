function draw_a_circle(Xc,Yc,R,titlename,colorfill)

if nargin < 5
    colorfill = [];
end
x=0:0.01:1; %x vector
y=0:0.01:1; %y vector

plot(Xc+R*cos(2*pi*x),Yc+R*sin(2*pi*y),'k','linewidth',1);
set(gca, 'visible', 'off'); 
if ~isempty(colorfill)
    patch(Xc+R*cos(2*pi*x),Yc+R*sin(2*pi*y),colorfill);
end
titlename = int2str(titlename);
switch length(titlename)
    case 1
        h = text(-R*0.15,0,titlename);
    case 2
        h = text(-R*0.35 ,0,titlename);
    otherwise
        h = text(-R*0.5 ,0,titlename);
end
set(h,'fontname','arial','fontweight','bold');
