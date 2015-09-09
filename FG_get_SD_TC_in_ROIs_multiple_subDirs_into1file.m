function FG_get_SD_TC_in_ROIs_multiple_subDirs_into1file
hmask=questdlg('Are you going to use one global-mask for all selected subjects or use different ROI & global-mask for different seclected subjects(In this case, ROI number should be equal to the selected Subjects)?', ...
            'Hi...','For all','1 by 1','For all') ;
if isempty(hmask), return , end 

anyreturn=FG_modules_selection('Select the root folder of multiple subfolders','Select the multiple subfolders','','','r','g');
if anyreturn, return;end 

 filefilter=inputdlg('Enter a file filter to select files under each subfolder:','File fileter...',1,{'.*img'})   ;
 filefilter= filefilter{1} ; 
    
   % selcet the gray-matter img
 % [the gray-matter img's voxel size & img dimention should be the same as the cbf imgs that will be selected later]
  % selcet the cbf imgs that will be masked by the selceted gray-matter mask
  
  if strcmp(spm('ver',[],1),'SPM5')|| strcmp(spm('ver',[],1),'SPM8')
       Gray = spm_select(Inf,'any','Select mutiple mask imgs', [],pwd,'.*img$|.*nii$');
  else  
       Gray = spm_get(Inf,'any','Select mutiple mask imgs'); 
  end
  
  if isempty(Gray), return , end  
  n_ROI=size(Gray,1);
    
  mask_names=spm_str_manip(Gray,'dcr');  % take use of the "spm_str_manip" function
 
    if size(mask_names,1)==1   % in this condition, [spm_str_manip(spm_str_manip(dirs,'dh'),'dc')] can't get the subject dirctories
       i=size(mask_names,2); 
       success=0;
       for j=i:-1:1
           if mask_names(j)==filesep
               success=1;
               break
           end
       end
       
       if success==1
           mask_names=mask_names(j+1:end);
       end
    end 
   
    for i=1:size(mask_names,1)
        mask_names1(i,:)=[' ' mask_names(i,:)];
    end
    mask_names=mask_names1;
    clear mask_names1
    
    if strcmp(hmask,'For all')
          brain = spm_select(1,'any','Select a whole brain mask,or skip this step~', [],pwd,'.*img$|.*nii$');
    elseif strcmp(hmask,'1 by 1')
          if size(groups,1)~=n_ROI
              fprintf('\n...I don''t know what do you want to do as the number of selected Imgs is different from the number of selected ROIs...\n')
              return
          else
              brain = spm_select(size(groups,1),'any','Select corresponding whole brain masks,or skip this step~', [],pwd,'.*img$|.*nii$');
          end
    end
 
   Val_range=inputdlg({'Enter the Low limit (You can use <GL> as a global-mean variable)';'Enter the upper limit (You can use <GL> as a global-mean variable)';},'Value range...',1,{'-inf'; 'inf'});
   
    
 all_subject_names=['all_subj_names_in_' num2str(size(mask_names,1)) 'roi_session_for_STD_TC.txt'];
 all_ROIs_names=['all_' num2str(size(mask_names,1)) 'roi_names_for_STD_TC.txt'];
 all_ROIs_TCs=['all_' num2str(size(mask_names,1)) 'roi_for_STD_TCs.csv']; 
   
   TC_write_all=[];
   for g=1:size(groups,1)
                    
       fprintf('\nDealing with the folder:   %s\n', groups(g,:))
          if strcmp(spm('ver',[],1),'SPM5') || strcmp(spm('ver',[],1),'SPM8')
             %  Filename = spm_select(Inf,'.img','Select images to be read', [],pwd,'.*img');
              Filename= spm_select('FPList',deblank(groups(g,:)),filefilter);
          %else  
          %     Filename = spm_get(Inf,'*.img','Select images to be read'); 
          end
          n_Img=size(Filename,1);
          
          
          files=spm_str_manip(Filename,'dc');  % take use of the "spm_str_manip" function
            
            a1=[1:size(files,1)]';
            b1=[files num2str(a1)]; %% add the order of the imgs

          write_name1=fullfile(root_dir,all_subject_names);
          if g==1
           dlmwrite(write_name1, b1, 'delimiter', '', 'newline','pc');
           dlmwrite(write_name1, ['------next group---------------'],'-append', 'delimiter', '', 'newline','pc');
          else
           dlmwrite(write_name1, b1,'-append', 'delimiter', '', 'newline','pc');
           dlmwrite(write_name1, ['------next group---------------'],'-append', 'delimiter', '', 'newline','pc');         
          end


         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         % files selcet   % end %
         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

         TC=[];
         
           if strcmp(hmask,'For all')
              p_low=1; p_high=n_ROI;
           elseif strcmp(hmask,'1 by 1')
              p_low=g; p_high=g;
           end
         
             for p=p_low:p_high

                fprintf('\n---dealing with your No. %s roi.....\n',num2str(p))  % process index shown in the command window ~~~~~

               [pth1,Name1,Ext1,Versn1] = fileparts(Gray(p,:));   
               VG = spm_vol(deblank(Gray(p,:)));  
               mask = double(logical(spm_read_vols(VG)));  % this gray-matter image is a gray image that can be used as a mask

                if strcmp(hmask,'For all') && p==1
                    if isempty(brain)  || strcmp(brain,'Non-wholebrain_mask')
                        V=spm_vol(deblank(Gray(1,:)));% read a piece cbf img
                        dat = spm_read_vols(V);   
                        brain_mask=ones(size(dat)); % that means no mask is used
                        clear V dat;
                        brain='Non-wholebrain_mask';
                    else     
                        V_brain = spm_vol(deblank(brain));
                        brain_mask = double(logical(spm_read_vols(V_brain)));
                    end
                elseif strcmp(hmask,'1 by 1')
                    if isempty(brain)  || strcmp(brain,'Non-wholebrain_mask')
                        V=spm_vol(deblank(Gray(p,:)));% read a piece cbf img
                        dat = spm_read_vols(V);   
                        brain_mask=ones(size(dat)); % that means no mask is used
                        clear V dat;
                        brain='Non-wholebrain_mask';
                    else     
                        V_brain = spm_vol(deblank(brain(g,:)));
                        brain_mask = double(logical(spm_read_vols(V_brain)));
                    end  
                end

               mask = mask.*brain_mask;   % this gray-matter image is .* with whole brain mask to generate a specific matter's(gray/white/csf) mask

              TC_tem=[];

                  %%%% voxel by voxel caculation %%%
                  for k=1:n_Img,
                        [pth,Name,Ext,Versn] = fileparts(Filename(k,:));
                        V=spm_vol(deblank(Filename(k,:)));
                        dat = spm_read_vols(V);   % read a piece cbf img
                     %   global_inten = spm_global(V); % get the original cbf img's global mean cbf value using "spm_global()" based on SPM

                      % caculate the gray-matter's global mean cbf
                        within_maskdat =[];
                        within_maskdat = dat.*mask; % create the cbf image masked by the gray-matter image 

                       % sum the voxel cbf values after excluding the "Nan" value voxels to
                       % global_mean=mean(within_maskdat(find(within_maskdat~=0)));  % this can't handle the voxels that really have value of "0"
                                
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
                           global_mean=std(within_mask_vaild_values); % average all the values that is Non-Nan within the mask (include all vaild '0's if there is some)                 
        % %                 within_mask_vaild_values=[];
        % %                 for i=1:V.dim(1)*V.dim(2)*V.dim(3)
        % %                     if within_maskdat(i)~=0 & ~isnan(within_maskdat(i))
        % %                         within_mask_vaild_values=[within_mask_vaild_values;within_maskdat(i)];  % the total_vaildvoxels must be equal the length(masked_vaild_values)
        % %                     end
        % %                 end
        % %                 global_mean=mean(within_mask_vaild_values);


                       TC_tem=[TC_tem;global_mean]; 

                   end;
                   TC=[TC,TC_tem];
                  % if you don't want to see the sequence number of each ROI in the output
                  % file in order to copy the potential MNI coordinates much more convenient 
                  % use these lines
                      %      if p==1
                      %          dlmwrite(fullfile(pth,'ROIs_names.txt'), [Name1], 'delimiter', '', 'newline','pc');
                      %      else
                      %          dlmwrite(fullfile(pth,'ROIs_names.txt'), [Name1],'-append', 'delimiter', '', 'newline','pc'); 
                      %      end
             end
         
        if n_Img>=1 
            TC_mean=mean(TC);
            [h,p_value,ci,stats]=ttest(TC,0,0.001,'both'); % alpha=0.001, two-tail


            TC_stats=[stats.df;TC_mean;stats.sd;stats.tstat;p_value;h];% df, mean, std, t-value, p-value, reject or not(1 reject;0 accept)
            if strcmp(hmask,'1 by 1')
                tem_nROI=1;
            elseif strcmp(hmask,'For all')
                tem_nROI=n_ROI;
            end
            
            for j=1:tem_nROI
                if TC_stats(4,j)<0
                    TC_stats(6,j)=TC_stats(6,j)*(-1);   % identify the negative significant
                end
              %  tem=sprintf('%1.4f',TC_stats(5,j));  % control the precision of the p-value data
              %  TC_stats(5,j)=str2num(tem);
            end
        end

            seps=NaN(1,tem_nROI);% the separation of the raw data and the statistical data in the sheet

            TC_write=[TC;seps;TC_stats];

            TC_write_all=[TC_write_all;TC_write;seps;seps;seps];        

   end
   
         
        write_name3=FG_check_and_rename_existed_file(fullfile(root_dir,all_ROIs_TCs));
        csvwrite(write_name3,TC_write_all) 
        % csvwrite([pth,filesep,'ROIs_TCs.dat'],TC_write) 
        
                a=[1:size(mask_names,1)]';
                %b=[num2str(a) nan(size(mask_names,1),1) mask_names];  % this doesn't work
                b=[num2str(a) mask_names];
                
                write_name2=FG_check_and_rename_existed_file(fullfile(root_dir,all_ROIs_names));
                dlmwrite(write_name2, b, 'delimiter', '', 'newline','pc');
                dlmwrite(write_name2, ['-------------stats---------------'],'-append', 'delimiter', '', 'newline','pc');
                dlmwrite(write_name2, ['df'],'-append', 'delimiter', '', 'newline','pc');
                dlmwrite(write_name2, ['mean'],'-append', 'delimiter', '', 'newline','pc');
                dlmwrite(write_name2, ['std'],'-append', 'delimiter', '', 'newline','pc');
                dlmwrite(write_name2, ['t-value'],'-append', 'delimiter', '', 'newline','pc');
                dlmwrite(write_name2, ['p-value'],'-append', 'delimiter', '', 'newline','pc');
                dlmwrite(write_name2, ['reject or not(two-tails,p=0.001;1 sig; 0 non-sig)'],'-append', 'delimiter', '', 'newline','pc');
                
                dlmwrite(write_name2, ['*********************'],'-append', 'delimiter', '', 'newline','pc');
                
                dlmwrite(write_name2, ['---the groups in the file----------------------'],'-append', 'delimiter', '', 'newline','pc');
                dlmwrite(write_name2, groups,'-append', 'delimiter', '', 'newline','pc');
                dlmwrite(write_name2, ['---the whole brain mask used here is----------------------'],'-append', 'delimiter', '', 'newline','pc');
                dlmwrite(write_name2, brain,'-append', 'delimiter', '', 'newline','pc');
                

        
fprintf('\n ---cbf TC has been saved into %s \n\n',write_name2)        
        
        
        
        
        
        