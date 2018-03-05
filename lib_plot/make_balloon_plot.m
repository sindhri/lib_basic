%need 2 change
%current balloon pop or win
%use the real pop/win result instead of using comparison
%maybe delete practice

%code pop as -1 and safe as 1

function make_balloon_plot(btable,study_name,nballoons,subnumber)

if nargin==3
    subnumber = '';
end

figure;

subject_id = btable(1,1);

bar_width = 0.5;
line_color = 'm';
btable = verify_balloon_unique(btable);
win = find(btable(:,5)==1);
lose = find(btable(:,5)==-1);

if ~isempty(win) && ~isempty(lose)
    bar(btable(win,2),btable(win,4),bar_width,'b');
    hold on;
    if strcmp(study_name,'YANG')
        switch subject_id
            case {3100,31020,31025,31037,31040,31045,31046,31053,...
                    31055,31064,31067,31069,31070,...
                    31071,31075,31079,31090,31098,31099,31101}
                bar_width_red = 0.23;
            case {31058,31066}
                bar_width_red = 0.15;
            case {31093,1}
                bar_width_red = 0.35;
            otherwise
                bar_width_red = bar_width;
        end
    else
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
ylabel('Pumps','Fontsize',14,'color','b');
h2 = axes('Position',get(h1,'Position'));
plot(btable(:,2),btable(:,3),line_color);

set(h2,'YAxisLocation','right','Color','none')
set(h2,'XTick',0:5:nballoons,'XTickLabel',0:5:nballoons);
set(h2,'XLim',get(h1,'XLim'),'YLim',get(h1,'YLim'),'Layer','top');
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