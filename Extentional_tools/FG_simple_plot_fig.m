function pfig=FG_simple_plot_fig(TCs,fig_name,SubplotorNo);
if nargin==1
    fig_name='Plot timecourses (columns)...';
    SubplotorNo=0;
elseif nargin==2
    SubplotorNo=0;
end
n_tc=size(TCs,2); %% columns
%%% show the output figure
figure('name',fig_name,'Units', 'normalized', 'Position', [0.2 0.2 0.6 0.7],'Resize','on');
pfig = gcf;
% Don't show figure in batch runs
set(pfig,'Visible','off'); 



if SubplotorNo==1
    for i=1:n_tc
        subplot(i,1,1);
        plot(1:size(TCs(:,i)),TCs(:,i)');
        xlabel('x');
        ylabel('xy-x value');
        text(size(TCs(:,i)),TCs(end,i)',['\leftarrow -TC(' num2str(i) ')'])
        set(gca,'XTick',1:3:size(TCs(:,i),1));
        ylim([min(TCs) max(TCs)+1]*1.05)
        grid(gca,'on') 
    end
else
    for i=1:n_tc
        plot(1:size(TCs(:,i)),TCs(:,i)');
        xlabel('x');
        ylabel('xy-x value');
        text(size(TCs(:,i),1),TCs(end,i)',['\leftarrow -TC(' num2str(i) ')'])
        set(gca,'XTick',1:3:size(TCs(:,i),1));
        ylim([min(TCs(:)) max(TCs(:))+1]*1.05)
        grid(gca,'on') 
        hold on
    end
end

   set(pfig,'Visible','on'); 
    %    saveas(pfig,fullfile(pwd,'Ref_motion.bmp'))        
   %%%     close(pfig)
