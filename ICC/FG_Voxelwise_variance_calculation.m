
function FG_Voxelwise_variance_calculation

% this script is used to creat a variance map of a group of (CBF) imgs
    clc
    root_dir = spm_select(1,'dir','Select the folder to store the output files(*.img)', [],pwd);
      if isempty(root_dir)
        return
      end
 

        img_g = spm_select(inf,'any','Select a group of normalized_imgs', [],pwd,'.*img$|.*nii$');
        if isempty(img_g)
            return
        end
        

  brain = spm_select(Inf,'any','Select a whole brain mask[Recomand!],or skip this step~ ', [],pwd,'.*img$|.*nii$');
    if isempty(brain)
        V=spm_vol(deblank(img_g(1,:)));% read a piece cbf img
        dat = spm_read_vols(V);   
        brain_mask=ones(size(dat)); % that means no mask is used
        clear V dat;
     else     
      V_brain = spm_vol(deblank(brain));
      brain_mask = spm_read_vols(V_brain);
    end
    
     
                       
 %% deal with a 4-d data-structure                      
                        
     
        img_V=spm_vol(img_g);
        img_dat=spm_read_vols(img_V);

      
      T_Vs=size(img_dat,1)*size(img_dat,2)*size(img_dat,3); % total_voxels
      
      img_data_reshaped=reshape(img_dat,T_Vs,size(img_dat,4))';
      brain_mask_reshaped=reshape(brain_mask,T_Vs,1)';
      
      img_data_reshaped_masked=img_data_reshaped;
      for i=1:size(img_dat,4)
          img_data_reshaped_masked(i,:)=img_data_reshaped_masked(i,:).*brain_mask_reshaped;          
      end
      
      
      var_dat=var(img_data_reshaped_masked);
      
      var_dat_reshaped=reshape(var_dat',size(img_dat,1),size(img_dat,2),size(img_dat,3));

          
  
  V=spm_vol(deblank(img_g(1,:)));% read a piece cbf img
  [a,b,c,d]=fileparts(V.fname);
       i=size(a,2); 
       success=0;
       for j=i:-1:1
           if a(j)==filesep
               success=1;
               break
           end
       end
       if success==1
           a=a(j+1:end);
       end
    
  
    V.fname=FG_check_and_rename_existed_file([root_dir  a  '_variance.img']);
    spm_write_vol(V,var_dat_reshaped);
    

  
fprintf('\n-----------------All set----------------------\n\n')