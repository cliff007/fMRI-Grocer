% plot the .csv or .txt/.mat TCs
function FG_Plot_TCs_overlay

clc
h_fig=[];
a=findobj('Tag','as_FG_overlay');
h_overlay=[];
if ~isempty(a)
    h_overlay=questdlg('Do you want to close the figurescreated by me before or overlay new lines into current figure?','Close or Overlay...','Close','Overlay','Close');
    if isempty(h_overlay), return;end
    if strcmp(h_overlay,'Close')
        % close all
        close (findobj('Tag','as_FG_overlay'));
        clear a
    elseif strcmp(h_overlay,'Overlay')
        h_fig=a;
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
            if i==1 && isempty(h_fig)
                h_fig=figure('name',[b c]);
                line_color=[0.2 0 1];
                edge_color=[0 0.5 0.5];                
                a_xlim=get(gca,'xlim');
                a_ylim=get(gca,'ylim');
            elseif i==1 && ~isempty(h_fig)
                Seeds(i)=rand(1);
                if i>1
                   if Seeds(i)-Seeds(i-1)<0.15
                       Seeds(i)=Seeds(i)+0.15;
                   end
                end
                randSeed=Seeds(i);
                
                line_color=[1 0 1]*randSeed;
                edge_color=[0.5 0.5 1]*randSeed;
                h_axes=findall(h_fig,'type','axes');
                a_xlim=get(h_axes,'xlim');
                a_ylim=get(h_axes,'ylim');
            elseif i~=1  && ~isempty(h_fig)
                h_axes=findall(h_fig,'type','axes');
                a_xlim=get(h_axes,'xlim');
                a_ylim=get(h_axes,'ylim');            
            end
            drawlines_columns_and_resetfigs(File,TCs,i,h_fig,line_color,edge_color,a_xlim,a_ylim,h_overlay)    
        end
    elseif strcmp(h,'By rows')
        for i=1:size(TCs,1)
            if i==1 && isempty(h_fig)
                h_fig=figure('name',[b c]);
                line_color=[0.2 0 1];
                edge_color=[0 0.5 0.5];                
                a_xlim=get(gca,'xlim');
                a_ylim=get(gca,'ylim');
            elseif i==1 && ~isempty(h_fig)
                Seeds(i)=rand(1);
                if i>1
                   if Seeds(i)-Seeds(i-1)<0.15
                       Seeds(i)=Seeds(i)+0.15;
                   end
                end
                randSeed=Seeds(i);
                line_color=[1 0 1]*rand(1);
                edge_color=[0.5 0.5 1]*rand(1);
                h_axes=findall(h_fig,'type','axes');
                a_xlim=get(h_axes,'xlim');
                a_ylim=get(h_axes,'ylim');
            elseif i~=1  && ~isempty(h_fig)
                h_axes=findall(h_fig,'type','axes');
                a_xlim=get(h_axes,'xlim');
                a_ylim=get(h_axes,'ylim');           
            end
            drawlines_rows_and_resetfigs(File,TCs,i,h_fig,line_color,edge_color,a_xlim,a_ylim,h_overlay)
        end   
    end        
 
    
%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%
%% subfunction to draw columns
    function drawlines_columns_and_resetfigs(File,TCs,i,h_fig,line_color,edge_color,a_xlim,a_ylim,h_overlay)                
            set(0,'CurrentFigure',h_fig)
            if i==1
                ylabel(['No.' num2str(i) ' column']);
                xlabel('Timepoints');
                set(h_fig,'Tag','as_FG_overlay');
                t_min=min(TCs(:,i));
                t_max=max(TCs(:,i));
                
                if isnan(t_min) || isnan(t_max) 
                    return                   
                elseif t_min==t_max
                    t_max=t_max*2;
                end
                
                if a_xlim(2)>size(TCs(:,i),1)+1
                    hig_xlimt=a_xlim(2);
                else
                    hig_xlimt=size(TCs(:,i),1)+1;
                end
                
                if a_ylim(2)>t_max+5
                    hig_ylimt=a_ylim(2);
                else
                    hig_ylimt=t_max+5;
                end                

                if a_ylim(1)>t_min
                    low_ylimt=t_min;
                else
                    low_ylimt=a_ylim(1);
                end    
                
                xlim([1,hig_xlimt]);
                ylim([low_ylimt,hig_ylimt]);
                h_axes=findall(h_fig,'type','axes');
                set(h_axes,'XTick',[1:2:hig_xlimt]);
                set(h_axes,'YTick',[low_ylimt:2*ceil((hig_ylimt-low_ylimt)/size(TCs(:,i),1)):hig_ylimt]);
                grid(h_axes,'on') 
            end
            tem_line_color=rand(1)*line_color/i;
            line([1:size(TCs,1)],TCs(:,i),'Color',tem_line_color,'LineStyle','-','Marker','o','LineWidth',2,...
            'MarkerEdgeColor',rand(1)*edge_color/i,...
            'MarkerFaceColor',rand(1)*edge_color/i,...
            'MarkerSize',3);
        
            hold on;
            plotMean(TCs(:,i),tem_line_color);
            [a,b,c,d]=FG_separate_files_into_name_and_path(File);
            [e,f]=FG_sep_group_and_path(a);
            tem=[' ..' filesep f filesep b];
            
            if ~isempty(h_overlay) && strcmp('Overlay',h_overlay)
                text(find(TCs(:,i)==max(TCs(:,i))),max(TCs(:,i)),[' <----- TC', num2str(i),tem],'HorizontalAlignment','left','Rotation',10,'color',tem_line_color);% why '\leftarrow' become invaild ??             
            else
                text(find(TCs(:,i)==max(TCs(:,i))),max(TCs(:,i)),[' <----- TC', num2str(i),tem],'HorizontalAlignment','left','color',tem_line_color);% why '\leftarrow' become invaild ??
            end
%% subfunction to draw rows
    function drawlines_rows_and_resetfigs(File,TCs,i,h_fig,line_color,edge_color,a_xlim,a_ylim,h_overlay)
            set(0,'CurrentFigure',h_fig)
            if i==1            
                ylabel(['No.' num2str(i) ' row']);
                xlabel('Timepoints');
                set(h_fig,'Tag','as_FG_overlay');
                t_min=min(TCs(i,:));
                t_max=max(TCs(i,:));
                
                if isnan(t_min) || isnan(t_max) 
                    return                   
                elseif t_min==t_max
                    t_max=t_max*2;
                end
                
                if a_xlim(2)>size(TCs(i,:),2)+1
                    hig_xlimt=a_xlim(2);
                else
                    hig_xlimt=size(TCs(i,:),2)+1;
                end
                
                if a_ylim(2)>t_max+5
                    hig_ylimt=a_ylim(2);
                else
                    hig_ylimt=t_max+5;
                end                

                if a_ylim(1)>t_min
                    low_ylimt=t_min;
                else
                    low_ylimt=a_ylim(1);
                end    
                
                xlim([1,hig_xlimt]);
                ylim([low_ylimt,hig_ylimt]);
                h_axes=findall(h_fig,'type','axes');
                set(h_axes,'XTick',[1:2:hig_xlimt]);
                set(h_axes,'YTick',[low_ylimt:2*ceil((hig_ylimt-low_ylimt)/size(TCs(i,:),2)):hig_ylimt]);
                grid(h_axes,'on')   
            end
                tem_line_color=rand(1)*line_color/i;
                line([1:size(TCs,2)],TCs(i,:),'Color',tem_line_color,'LineStyle','-','Marker','o','LineWidth',2,...
                'MarkerEdgeColor',rand(1)*edge_color/i,...
                'MarkerFaceColor',rand(1)*edge_color/i,...
                'MarkerSize',3);           
                
                hold on;           
                plotMean(TCs(i,:),tem_line_color);    
                
                [a,b,c,d]=FG_separate_files_into_name_and_path(File);
                [e,f]=FG_sep_group_and_path(a);
                tem=[' ..' filesep f filesep b];
                
                if ~isempty(h_overlay) && strcmp('Overlay',h_overlay)
                    text(find(TCs(i,:)==max(TCs(i,:))),max(TCs(i,:)),[' <----- TC', num2str(i),tem],'HorizontalAlignment','left','Rotation',10,'color',tem_line_color);% why '\leftarrow' become invaild ??             
                else
                    text(find(TCs(i,:)==max(TCs(i,:))),max(TCs(i,:)),[' <----- TC', num2str(i),tem],'HorizontalAlignment','left','color',tem_line_color);% why '\leftarrow' become invaild ??
                end            
                
               
        
%% a subfunction to draw the mean line
        function plotMean(TC,tem_line_color)
            xlimits = get(gca,'XLim');
            meanValue = mean(TC);
            if isnan(meanValue)
               fprintf('\n-----Warning: your values may have NaN values, the blue mean line is based on the Non-NaN values!--------------\n')
               meanValue = mean(TC(find(~isnan(TC))));
            end
            line([xlimits(1) xlimits(2)],[meanValue meanValue],'Color',tem_line_color,'LineStyle','-.');
