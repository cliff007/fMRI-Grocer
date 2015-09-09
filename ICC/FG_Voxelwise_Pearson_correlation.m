
function FG_Voxelwise_Pearson_correlation
    clc
    root_dir = spm_select(1,'dir','Select the folder to store the output files(*.img)', [],pwd);
      if isempty(root_dir)
        return
      end
      


    for i=1:2 % to deal with the Pearson correlation, only two groups are allowed    
        img_g = spm_select(inf,'any',['Select all the normalized_imgs of ' num2str(i) '/2 group'], [],pwd,'.*img$|.*nii$');
        if isempty(img_g)
            return
        end
        eval(['imgs_pair_' num2str(i) '=img_g;']);
        if i>1
            if eval(['size(imgs_pair_' num2str(i) ',1)~=size(imgs_pair_', num2str(i-1) ',1)'])
                fprintf('\nError:This group''s subj number is different from your last group!....\n\n') 
                return  %% no missing data allow!!
            end
        end
    end

  brain = spm_select(Inf,'any','Select a whole brain mask[Recomand!],or skip this step~ ', [],pwd,'.*img$|.*nii$');
    if isempty(brain)
        V=spm_vol(deblank(imgs_pair_1(1,:)));% read a piece cbf img
        dat = spm_read_vols(V);   
        brain_mask=ones(size(dat)); % that means no mask is used
        clear V dat;
     else     
      V_brain = spm_vol(deblank(brain));
      brain_mask = spm_read_vols(V_brain);
    end
    
    
    % specify the num of imgs in each subject's dir
    dlg_prompt={'Set the Alpha-level of r-test:','How to deal with the missing value: all or complete or pairwise ?'};
    dlg_name='Pearson Correlation... ("help corrcoef" in MATLAB)';
    dlg_def={'0.05','all'};    
    Ans=inputdlg(dlg_prompt,dlg_name,1,dlg_def,'on');  
    
    
     k=logical(brain_mask);  % just to make sure it is a binary img.
     for i=1:2       
        Vmat=spm_vol(eval(['imgs_pair_' num2str(i)]));
        V=spm_read_vols(Vmat);
        for j=1:size(V,4)
            tem=V(:,:,:,j);
            tem(find(isnan(tem)))=0; % set the NaN voxels into 0
            V(:,:,:,j)=tem; % set the NaN voxels into 0
        end    
        eval(['V_g' num2str(i) '=V;']);

        % in order to deal with the situation that some voxels in some subjs
        % are 0, we need to get a common mask within a group
        for j=1:size(V,4)
            k=k.*eval(['V_g' num2str(i) '(:,:,:,' num2str(j) ');']);
        end
        group_mask=logical(k); % get the mask within a group.
        eval([' group_mask_g' num2str(i) '= group_mask;']);
     end
     
 
 
    
    % in order to deal with the situation that some voxels in some group
    % are 0, we need to get a common mask across groups
   k=[]; 
   k=logical(brain_mask);
   for i=1:2 
      k=k.*eval(['group_mask_g' num2str(i)]);
   end
   Gp_mask=logical(k); % get the mask across groups.
   
                       
 %% an improved algorithm                      
                        
       Temp=[];
       for i=1:2  % loops across the groups
           sub=[];    % voxel values of a group of subjs in a voxel                
           for j=1:size(V,4) % loops across subjects
               eval(['Temp=V_g' num2str(i) '(:,:,:,' num2str(j) ');'])
               sub=[sub Temp(:)]; % store matrix values as a vector
           end
           eval(['Gp_sub' num2str(i) '=sub;']);
       end                        
      
       fprintf('\n--- Pearson''s r is being calculated, start timing.................\n')
       fprintf('\n--- It may takes quite a few minutes, be patient...\n')
       tic
      
      r1=[];  p1=[]; 
      r=double(Gp_mask(:)); % be careful, GP_mask now is a logical variable, you need to change it into normal variable
      p=r; 
      ids=find(Gp_mask==1); %% find out all the voxel that need to be calculate ICC
      
      
      T_Vs=size(Gp_mask,1)*size(Gp_mask,2)*size(Gp_mask,3); % total_voxels
      for j=1:size(ids,1) % deal with the calculation voxel by voxel
          
              x=ids(j); % loop within ids 
              M=[];  % voxel values of all groups of subjs in a voxel
            
              % for pearson, only deal with two groups
                     [r1, p1] = corrcoef(eval(['Gp_sub' num2str(1) '(' num2str(x) ',:)'';']), eval(['Gp_sub' num2str(2) '(' num2str(x) ',:)'';']), ...
                         'alpha',str2num(deblank(Ans{1})),'rows',deblank(Ans{2}));
                     eval(['r(' num2str(x) ')  = r1(1,2);']);
                     eval(['p(' num2str(x) ')  = p1(1,2);']);
                     
        
              if mod(x, 10000)==1
                  fprintf('--- %d / %d voxels are done! Running...\n',x,T_Vs)
              end
      end
          
      fprintf('\n--- Calculation of Pearson''s r is done!.................\n')
      total_t= toc; 
      fprintf('\n--- It takes totally %s mins!!!\n',num2str(total_t/60))
      
                        
       r=reshape(r,size(Gp_mask));
       p=reshape(p,size(Gp_mask));  
  
  V=spm_vol(deblank(imgs_pair_1(1,:)));% read a piece cbf img
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
    
  
    V.fname=FG_check_and_rename_existed_file([root_dir  a  '_Pearson_r_value_sig(at_' deblank(Ans{1}) ').img']);
  %  r(find(abs(p)>str2num(deblank(Ans{1}))))=0; % find out all the voxels that have a sig. r-test
    spm_write_vol(V,r);
    

  
fprintf('\n---------------------------All set!!!!!!!!!!---\n\n')