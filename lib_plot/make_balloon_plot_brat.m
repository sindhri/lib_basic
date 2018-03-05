%need 2 change
%current balloon pop or win
%use the real pop/win result instead of using comparison
%maybe delete practice

%code pop as -1 and safe as 1

function make_balloon_plot_brat(btable,study_name,nballoons,subnumber)

if nargin==3
    subnumber = '';
end

subject_id = btable(1,1);
figure;
bar_width = 0.5;
line_color = 'm';
btable = verify_balloon_unique(btable);
win = find(btable(:,5)==1);
lose = find(btable(:,5)==-1);

if ~isempty(win) && ~isempty(lose)
    bar(btable(win,2),btable(win,4),bar_width,'b');
    hold on;
    switch subject_id
        case {31047,31035, 31076, 31084, 31098, 31100, 31102}
            bar_width_red = 0.27;
        case 31060
            bar_width_red = 0.15;
        otherwise
            bar_width_red = bar_width;
    end
    bar(btable(lose,2),btable(lose,4),bar_width_red,'r');
    legend('win','lose');
else
    if ~isempty(win)
       bar(btable(win,2),btable(win,4),bar_width,'b');
       legend('win');
    else
       bar(btable(win,2),btable(win,4),bar_width,'r');
       legend('lose');
    end
end

h1 = gca;
set(h1,'XLim',[0,nballoons+1],'YLim',[0,128],'XTickLabel','');
ylabel('Deflates','Fontsize',14,'color','b');
h2 = axes('Position',get(h1,'Position'));
plot(btable(:,2),btable(:,3),line_color);

set(h2,'YAxisLocation','right','Color','none','XTick',0:5:nballoons,...
    'XTickLabel',0:5:nballoons);
set(h2,'XLim',get(h1,'XLim'),'YLim',get(h1,'YLim'),'Layer','top');
set(h2,'YTickLabel',{'128','108','88','68','48','28','8'});
xlabel('Balloon number','Fontsize',14);
ylabel('Pop Point','Fontsize',14,'color',line_color);
title([study_name '-' num2str(subject_id)],'Fontsize',14);
hold off;

saveas(gcf,['plots_' study_name '/p' num2str(subject_id) '_' study_name subnumber],'jpg');
close;
end


function btable = verify_balloon_unique(btable)
    if length(unique(btable(:,2))) < size(btable,1)
        test_array = btable(:,2);
        unique_array = [];
        mark_array = [];
        for i = 1:length(test_array)
            if i>1
                temp = find(test_array(1:i-1) == test_array(i));
            else
                temp = [];
            end
            if ~isempty(temp)
                mark_array = [mark_array, temp'];
            else
                unique_array = [unique_array, test_array(i)];
            end
        end
        fprintf('delete duplicates in subject ')
        fprintf([num2str(btable(1,1)) ' balloon ']);
        fprintf([num2str(mark_array)  '\n']);
        btable(mark_array,:) = [];
    end
end