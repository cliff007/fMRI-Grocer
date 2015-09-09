function FG_sum_GrayWhite_to_create_individual_mask
% this script can help you to calculate up all the whites and grays
% this is used to build all subjs' individual brain mask
        root_dir = spm_select(1,'dir','Select the root folder of all T1 segments', [],pwd);
              if isempty(root_dir)
                return
             end   

        cd (root_dir)
        Grays =  spm_select(inf,'any','Select all the gray matters ', [],pwd,'^c1.*nii$|^c1.*img$');
                Gs=spm_str_manip(Grays,'dc');  % take use of the "spm_str_manip" function
                if size(Gs,1)==1   % in this condition, [spm_str_manip(spm_str_manip(Gs,'dh'),'dc')] can't get the group dirctories
                    [a,b,c,d]=fileparts(Grays(1,:));
                    Gs=[b c];
                end
        Whites =  spm_select(inf,'any','Select all the white matters ', [],pwd,'^c2.*nii$|^c2.*img$');
                Ws=spm_str_manip(Whites,'dc');  % take use of the "spm_str_manip" function
                if size(Ws,1)==1   % in this condition, [spm_str_manip(spm_str_manip(Gs,'dh'),'dc')] can't get the group dirctories
                    [a,b,c,d]=fileparts(Whites(1,:));
                    Ws=[b c];
                end               
            
        if size(Grays,1)~=size(Whites,1)
            pfrintf('\nThe num of Grays, Whites and CSFs is not the same!\n')
            return
        end
        
        T1_Vout=spm_vol(Grays(1,:));
        [path_t1, b,c,Sum_mask]=FG_separate_files_into_name_and_path(Grays,'Binary_GW_','prefix');
         for i=1:size(Grays,1)
             T1_Vout.fname=deblank(Sum_mask(i,:));
             tem_imgs=strvcat(Grays(i,:),Whites(i,:));
             spm_imcalc_ui(tem_imgs,T1_Vout.fname,'sum(X)>0',{1,0,4,0});                  
         end         
         
         % imfill the sum of the mask
         [path_t1, b,c,Filled_mask]=FG_separate_files_into_name_and_path(Sum_mask,'Filled_','prefix');
         fprintf('\n ------Filling the gap in the Gray+White image...\n');  
         for i=1:size(Grays,1)
            FG_fill_inside_Graymatter(Sum_mask(i,:),0);
         end
         
         % smooth the filled mask
         s_filled_Vout=spm_vol(Filled_mask(1,:));
         [path_t1, b,c,s_Filled_mask]=FG_separate_files_into_name_and_path(Filled_mask,'s_','prefix');
         fprintf('\n ------Smoothing the imfilled mask image...\n');  
         for i=1:size(s_Filled_mask,1)  % do a light smooth to the original resliced mask before imfill
             s_filled_Vout.fname=deblank(s_Filled_mask(i,:)); 
             spm_smooth(Filled_mask(i,:),s_filled_Vout.fname,[3 3 3]);  %  spm_smooth(P,Q,s,dtype)
         end        
         
          % binary the smoothed mask again
          filled_Vout=spm_vol(s_Filled_mask(1,:));
          [path_t1, b,c,Filled_mask]=FG_separate_files_into_name_and_path(s_Filled_mask,'Binarized_','prefix');
          fprintf('\n ------Binarizing the smoothed imfilled mask image...\n');  
          for i=1:size(Filled_mask,1)
              filled_Vout.fname=deblank(Filled_mask(i,:)); 
              spm_imcalc_ui(s_Filled_mask(i,:),filled_Vout.fname,'i1>0',{0,0,4,0});  
          end
%          
%          for i=1:size(Grays,1)
%                % delete a temporary files
%                  delete (deblank(s_Filled_mask))
%          end
        
        fprintf('\n -----------Individual  masks have been created!\n');  

        

        
        

