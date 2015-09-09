 function  FG_get_meanCBF_TC_in_ROIs_singlesubDir

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % files selcet   % start 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    hmask=questdlg('Are you going to apply all ROI(s) for all selected image or apply different ROIs for different Imgs(In this case, ROI number should be equal to the selected Imgs)?', ...
            'Hi...','For all','1 by 1','For all') ;
    if isempty(hmask), return , end 

      if strcmp(spm('ver',[],1),'SPM5')||strcmp(spm('ver',[],1),'SPM8')
           Filename = spm_select(Inf,'any','Select images to be read', [],pwd,'.*img$|.*nii$');
      else  
           Filename = spm_get(Inf,'any','Select images to be read'); 
      end
      if isempty(Filename),return,  end

      if strcmp(spm('ver',[],1),'SPM5')||strcmp(spm('ver',[],1),'SPM8')
           ROIs = spm_select(Inf,'any','Select mutiple ROI-mask imgs', [],pwd,'.*img$|.*nii$');
      else  
           ROIs = spm_get(Inf,'any','Select mutiple ROI-mask imgs'); 
      end
      if isempty(ROIs), return, end

      
  n_ROI=size(ROIs,1);
  n_Img=size(Filename,1);
  % selcet the gray-matter img
 % [the gray-matter img's voxel size & img dimention should be the same as the cbf imgs that will be selected later]
  % selcet the cbf imgs that will be masked by the selceted gray-matter mask
        
    if strcmp(hmask,'For all')
          brain = spm_select(1,'any','Select a whole brain mask,or skip this step~', [],pwd,'.*img$|.*nii$');
    elseif strcmp(hmask,'1 by 1')
          if n_Img~=n_ROI
              fprintf('\n...I don''t know what do you want to do as the number of selected Imgs is different from the number of selected ROIs...\n')
              return
          else
              brain = spm_select(n_Img,'any','Select corresponding whole brain masks,or skip this step~', [],pwd,'.*img$|.*nii$');    
          end
    end
  
   Val_range=inputdlg({'Enter the Low limit (You can use <GL> as a global-mean variable)';'Enter the upper limit (You can use <GL> as a global-mean variable)';},'Value range...',1,{'-inf'; 'inf'});

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % files selcet   % end %
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
 TC=[];

 for p=1:n_ROI 
     
   fprintf('\n---dealing with your No. %s roi.....\n',num2str(p))  % process index shown in the command window ~~~~~
   
   [pth1,Name1,Ext1,Versn1] = fileparts(ROIs(p,:));   
   VG = spm_vol(deblank(ROIs(p,:)));  
   G_tem=spm_read_vols(VG);
   G_tem(isnan(G_tem))=0;
   mask = double(logical(G_tem));  % this gray-matter image is a gray image that can be used as a mask
   
    if strcmp(hmask,'For all')
        if isempty(brain) || strcmp(brain,'Non-wholebrain_mask')
            V=spm_vol(deblank(ROIs(p,:)));% read a piece cbf img
            dat = spm_read_vols(V);   
            brain_mask=ones(size(dat)); % that means no mask is used
            clear V dat;
            brain='Non-wholebrain_mask';
        else     
            V_brain = spm_vol(deblank(brain));
            brain_tem=spm_read_vols(V_brain);
            brain_tem(isnan(brain_tem))=0;
            brain_mask = double(logical(brain_tem));
        end
    elseif strcmp(hmask,'1 by 1')
        if isempty(brain)  || strcmp(brain,'Non-wholebrain_mask')
            V=spm_vol(deblank(ROIs(p,:)));% read a piece cbf img
            dat = spm_read_vols(V);   
            brain_mask=ones(size(dat)); % that means no mask is used
            clear V dat;
            brain='Non-wholebrain_mask';
        else     
            V_brain = spm_vol(deblank(brain(p,:)));
            brain_tem=spm_read_vols(V_brain);
            brain_tem(isnan(brain_tem))=0;
            brain_mask = double(logical(brain_tem));
        end      
    end
    
   mask = mask.*brain_mask;   % this gray-matter image is .* with whole brain mask to generate a specific matter's(gray/white/csf) mask
   
  TC_tem=[];
 
   if strcmp(hmask,'For all')
      k_low=1; k_high=n_Img;
   elseif strcmp(hmask,'1 by 1')
      k_low=p; k_high=p;
   end
  
      %%%% voxel by voxel caculation %%%
      for k=k_low:k_high,
            [pth,Name,Ext,Versn] = fileparts(Filename(k,:));
            V=spm_vol(deblank(Filename(k,:)));
            dat = spm_read_vols(V);   % read a piece cbf img
         % global_inten = spm_global(V); 
         % get the original cbf img's global mean cbf value using "spm_global()" based on SPM caculate the gray-matter's global mean cbf
            within_maskdat =[];
            within_maskdat = dat.*mask; % create the cbf image masked by the gray-matter image 

           % sum the voxel cbf values after excluding the "Nan" value
           % voxels to global_mean=mean(within_maskdat(find(within_maskdat~=0)));  
           % this can't handle the voxels that really have value of "0"
               GL_tem=dat.*brain_mask;
               GL_tem=GL_tem(:); GL_tem(GL_tem==0)=[];
               GL=mean(GL_tem(:));  % define this global_mean for potential using
               if isempty(regexpi(Val_range{1},'GL'))
                   low_lim=str2num(Val_range{1});
               else
                   low_lim=eval(Val_range{1});
               end          

               if isempty(regexpi(Val_range{2},'GL'))
                   up_lim=str2num(Val_range{2});
               else
                   up_lim=eval(Val_range{2});
               end  
               
               
               within_mask_vaild_values=[];
               within_mask_vaild_values=within_maskdat(find(mask~=0));
               within_mask_vaild_values=within_mask_vaild_values(find(~isnan(within_mask_vaild_values)));
               within_mask_vaild_values(within_mask_vaild_values<low_lim)=[]; % threshold the data value range
               within_mask_vaild_values(within_mask_vaild_values>up_lim)=[];
               global_mean=mean(within_mask_vaild_values); % average all the values that is Non-Nan within the mask (include all vaild '0's if there is some)  
               TC_tem=[TC_tem;global_mean]; 

       end;
       
        TC=[TC,TC_tem];   
        
        write_name2=FG_check_and_rename_existed_file(fullfile(pth,'ROIs_TCs.csv'));
        % if you want to see the sequence number of each ROI in the output file, use these lines
        if p==1
            write_name1=FG_check_and_rename_existed_file(fullfile(pth,'ROIs_names.txt'));
            dlmwrite(write_name1, [num2str(p) '    ' Name1], 'delimiter', '', 'newline','pc');
        else
            dlmwrite(write_name1, [num2str(p) '    ' Name1],'-append', 'delimiter', '', 'newline','pc'); 
        end

          % if you don't want to see the sequence number of each ROI in the output
          % file in order to copy the potential MNI coordinates much more convenient 
          % use these lines
              %      if p==1
              %          dlmwrite(write_name1, [Name1], 'delimiter', '', 'newline','pc');
              %      else
              %          dlmwrite(write_name1, [Name1],'-append', 'delimiter', '', 'newline','pc'); 
              %      end
 end       
      
    if n_Img>1 && strcmp(hmask,'For all')
        TC_mean=mean(TC);
        [h,p_value,ci,stats]=ttest(TC,0,0.001,'both'); % alpha=0.001, two-tail
      
             
        TC_stats=[stats.df;TC_mean;stats.sd;stats.tstat;p_value;h];% df, mean, std, t-value, p-value, reject or not(1 reject;0 accept)
        for j=1:n_ROI
            if TC_stats(4,j)<0
                TC_stats(6,j)=TC_stats(6,j)*(-1);   % identify the negative significant
            end
          %  tem=sprintf('%1.4f',TC_stats(5,j));  % control the precision of the p-value data
          %  TC_stats(5,j)=str2num(tem);
        end
     end
        
        seps=NaN(2,n_ROI);% the separation of the raw data and the statistical data in the sheet
        
        
    if n_Img>1 && strcmp(hmask,'For all')      
        TC_write=[TC;seps;TC_stats];
    else 
        TC_write=[TC;seps];
    end
        
        dlmwrite(write_name1, ['-------------stats---------------'],'-append', 'delimiter', '', 'newline','pc');
        dlmwrite(write_name1, ['df'],'-append', 'delimiter', '', 'newline','pc');
        dlmwrite(write_name1, ['mean'],'-append', 'delimiter', '', 'newline','pc');
        dlmwrite(write_name1, ['std'],'-append', 'delimiter', '', 'newline','pc');
        dlmwrite(write_name1, ['t-value'],'-append', 'delimiter', '', 'newline','pc');
        dlmwrite(write_name1, ['p-value'],'-append', 'delimiter', '', 'newline','pc');
        dlmwrite(write_name1, ['reject or not(two-tails,p=0.001;1 sig; 0 non-sig)'],'-append', 'delimiter', '', 'newline','pc');
        dlmwrite(write_name1, ['---the whole brain mask used here is----------------------'],'-append', 'delimiter', '', 'newline','pc');
        dlmwrite(write_name1, brain,'-append', 'delimiter', '', 'newline','pc');
                
        csvwrite(write_name2,TC_write)   
   
       % plot the TCs
       if size(TC,1)>=2
           figure('name',write_name2); 
           line_color=[1 0 1];
           edge_color=[0.5 0.5 1];
           axes('position',[.05  .1  .7  .8])

           for i=1:size(TC,2)                
                
                t_min=min(TC(:));
                t_max=max(TC(:));

                if isnan(t_min) || isnan(t_max) 
                    return                   
                elseif t_min==t_max
                    t_max=t_max*2;
                end    

                xlim([1,size(TC,1)+1]);
                ylim([t_min,t_max+5]);
                set(gca,'XTick',[1:2:size(TC,1)+1]);
                set(gca,'YTick',[t_min:2*ceil((t_max-t_min)/size(TC,1)):t_max+5]);
                grid(gca,'on')                 
                
                Seeds(i)=rand(1);
                if i>1
                   if Seeds(i)-Seeds(i-1)<0.01
                       Seeds(i)=Seeds(i)+0.2;
                   end
                end
                randSeed=Seeds(i);

                
                tem_line_color=randSeed*line_color/i;
                line([1:size(TC(:,i),1)],TC(:,i),'Color',tem_line_color,'LineStyle','-','Marker','o','LineWidth',2,...
                'MarkerEdgeColor',randSeed*edge_color/i,...
                'MarkerFaceColor',randSeed*0.5*edge_color/i,...
                'MarkerSize',3);  
                hold on;
                plotMean(TC(:,i),tem_line_color); 

                [a,b]=FG_separate_files_into_name_and_path(deblank(ROIs(i,:)));
                text(size(TC(:,i),1),TC(end,i),['\leftarrow' b],'HorizontalAlignment','left','color',tem_line_color);
           end
       end
       
% %       [a,b]=FG_separate_files_into_name_and_path(ROIs);
% %       legend('Location','NorthEastOutside'); % draw the legends with original names
% %       [c,d,e,f]=legend;
% %       legend(e(1:2:end),b,'Location','NorthEastOutside');  % rename the ODD legends and delete the EVEN legends automatically       
% % %       title(gca,write_name2) 

      
       
fprintf('\n ---cbf TC has been saved into %s \n\n',write_name2)
 

%% a subfunction to draw the mean line
        function plotMean(TC,tem_line_color)
            xlimits = get(gca,'XLim');
            meanValue = mean(TC);
            if isnan(meanValue)
               fprintf('\n-----Warning: your values may have NaN values, the blue mean line is based on the Non-NaN values!--------------\n')
               meanValue = mean(TC(find(~isnan(TC))));
            end
            line([xlimits(1) xlimits(2)],[meanValue meanValue],'Color',tem_line_color,'LineStyle','-.');
%             clear meanValue
        