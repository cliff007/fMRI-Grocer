% plot the .csv or .txt/.mat TCs
function FG_Plot_TCs

clc
a=findobj('Tag','as_FG');
if ~isempty(a)
    h=questdlg('Do you want to close all the figures created by me before?','Close all or not...','Yes','No','Yes');
    if isempty(h), return;end
    if strcmp(h,'Yes')
        % close all
        close (findobj('Tag','as_FG'));
        clear a
    end
end


File = spm_select(1,'any','Select a TC file to be read', [],pwd,'.*txt$|.*mat$|.*csv$');
if isempty(File), return;end
[a,b,c,d]=fileparts(File);

% read the files
switch c
    case {'.txt','.mat'}
        TCs=load(File) ;     
    case '.csv'   
        TCs=csvread(File) ;  
end

% main program
    h=questdlg('What direction of your Timecouse?','TC direction...','By rows','By columns','By columns');
    if strcmp(h,'By columns')
        for i=1:size(TCs,2)
            drawlines_columns_and_resetfigs(File,TCs,i)    
        end
    elseif strcmp(h,'By rows')
        for i=1:size(TCs,1)
            drawlines_rows_and_resetfigs(File,TCs,i)
        end   
    end        
 
    
%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%
%% subfunction to draw columns
    function drawlines_columns_and_resetfigs(File,TCs,i)
               h=figure('name',File);
                plot([1:size(TCs,1)],TCs(:,i),'-ro','LineWidth',2,...
                'MarkerEdgeColor','k',...
                'MarkerFaceColor','g',...
                'MarkerSize',5);
            
                ylabel(['No.' num2str(i) ' column']);
                xlabel('Timepoints');
                set(h,'Tag','as_FG');
                t_min=min(TCs(:,i));
                t_max=max(TCs(:,i));
                
                if isnan(t_min) || isnan(t_max) 
                    return                   
                elseif t_min==t_max
                    t_max=t_max*2;
                end
                
                xlim([1,size(TCs(:,i),1)+1]);
                ylim([t_min,t_max+5]);
                set(gca,'XTick',[1:2:size(TCs(:,i),1)+1]);
                set(gca,'YTick',[t_min:2*ceil((t_max-t_min)/size(TCs(:,i),1)):t_max+5]);
                grid(gca,'on')   
                plotMean(TCs(:,i));
        
                % reset the figure position  --start              
                a=get(h,'Position');
                b=get(0,'ScreenSize') ;                
                if size(TCs,1)>1
                    if (b(3)/size(TCs,2))<a(3)
                        set(h,'Position',[(i-1)*b(3)/size(TCs,2) a(2) b(3)/size(TCs,2) a(4)])
                    else
                        set(h,'Position',[(i-1)*a(3) a(2) a(3) a(4)])
                    end
                end
                % reset the figure position  --done   


%% subfunction to draw rows
    function drawlines_rows_and_resetfigs(File,TCs,i)
                h=figure('name',File);
                plot([1:size(TCs,2)],TCs(i,:),'-ro','LineWidth',2,...
                'MarkerEdgeColor','k',...
                'MarkerFaceColor','g',...
                'MarkerSize',5);
            
                ylabel(['No.' num2str(i) ' row']);
                xlabel('Timepoints');
                set(h,'Tag','as_FG');
                t_min=min(TCs(i,:));
                t_max=max(TCs(i,:));
                
                if isnan(t_min) || isnan(t_max) 
                    return                   
                elseif t_min==t_max
                    t_max=t_max*2;
                end
                
                xlim([1,size(TCs(i,:),2)+1]);
                ylim([t_min,t_max+5]);
                set(gca,'XTick',[1:2:size(TCs(i,:),2)+1]);
                set(gca,'YTick',[t_min:2*ceil((t_max-t_min)/size(TCs(i,:),1)):t_max+5]);
                grid(gca,'on')   
                plotMean(TCs(i,:));
        
                % reset the figure position  --start              
                a=get(h,'Position');
                b=get(0,'ScreenSize') ;                
                if size(TCs,1)>1
                    if (b(3)/size(TCs,1))<a(3)
                        set(h,'Position',[(i-1)*b(3)/size(TCs,1) a(2) b(3)/size(TCs,1) a(4)])
                    else
                        set(h,'Position',[(i-1)*a(3) a(2) a(3) a(4)])
                    end
                end
                % reset the figure position  --done

        
        
        
%% a subfunction to draw the mean line
        function plotMean(TC)
            xlimits = get(gca,'XLim');
            meanValue = mean(TC);
            if isnan(meanValue)
               fprintf('\n-----Warning: your values may have NaN values, the blue mean line is based on the Non-NaN values!--------------\n')
               meanValue = mean(TC(find(~isnan(TC))));
            end
            line([xlimits(1) xlimits(2)],[meanValue meanValue],'Color','b','LineStyle','-.');
