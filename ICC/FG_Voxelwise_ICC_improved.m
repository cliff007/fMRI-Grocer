
function FG_Voxelwise_ICC_improved
    clc
    root_dir = spm_select(1,'dir','Select the folder to store the output files', [],pwd);
      if isempty(root_dir)
        return
      end
      
    % specify the num of imgs in each subject's dir
    dlg_prompt={'How many groups (Repeated measure times) do you have to calculate ICC:','ICC-type (read <McGraw (1996)> and <FG_ICC.m> to select): ','ICC-Alpha Level:','ICC-base line:'};
    dlg_name='ICC parameters setup.....';
    dlg_def={'2','C-k (or: 1-1; 1-k; C-1; A-1; A-k)','0.05','0'}; % A- absolute value, C- consistency£¬ 1- single£¬ k- average;
    
    %%
        % ICC(1,1): used when each subject is rated by multiple raters, raters assumed to be randomly assigned to subjects, all subjects have the same number of raters.
        % ICC(2,1): used when all subjects are rated by the same raters who are assumed to be a random subset of all possible raters.
        % ICC(3,1): used when all subjects are rated by the same raters who are assumed to be the entire population of raters.
        % ICC(1,k): Same assumptions as ICC(1,1) but reliability for the mean of k ratings.
        % ICC(2,k): Same assumptions as ICC(2,1) but reliability for the mean of k ratings.
        % ICC(3,k): Same assumptions as ICC(3,1) but reliability for the mean of k ratings. Assumes additionally no subject by judges interaction.

    
    
   % dlg_def={'2','1-1','0.05','0'};
    Ans=inputdlg(dlg_prompt,dlg_name,1,dlg_def);  
    n_groups=str2num(Ans{1});
    type=Ans{2};
    alpha=str2num(Ans{3});
    r0=str2num(Ans{4});
    clear Ans
    
    
    imgs_g=[];
    for i=1:n_groups    
        imgs_g{i} = spm_select(inf,'any',['Select all the normalized_imgs of ' num2str(i) '/' num2str(n_groups) ' group'], [],pwd,'.*img$|.*nii$');
        if isempty(imgs_g)
            return
        end
        
        if i>1
            if size(imgs_g{i} ,1)~=size(imgs_g{i-1},1)
                fprintf('\nError:This group''s subj number is different from your last group!....\n\n') 
                return  %% no missing data allowed!!
            end
        else
            n_subj=size(imgs_g{i} ,1);
        end
    end

  brain = spm_select(Inf,'any','Select a whole brain mask[Recommand!],or skip this step~ ', [],pwd,'.*img$|.*nii$');
  pause(0.5)
  fprintf('\n--- Dealing with the mask..........\n')
    if isempty(brain)
        V=spm_vol(deblank(imgs_g{1}(1,:)));% read a piece cbf img       
        brain_mask=ones(V.dim); % that means no mask is used
        clear V
     else     
      V_brain = spm_vol(deblank(brain));
      brain_mask = spm_read_vols(V_brain);
      clear V_brain
    end
    
    for i=1:n_groups       
        Vmat=spm_vol(imgs_g{i});
        V=spm_read_vols(Vmat);
        V=FG_make_sure_NaN_to_zero_img(V);
        V_g{i}=V;
        clear Vmat V

%         % in order to deal with the situation that some voxels in some subjs
%         % are 0, we need to get a common mask within a group
%         for j=1:size(V,4)
%             k=k.*eval(['V_g' num2str(i) '(:,:,:,' num2str(j) ');']);
%         end
%         group_mask=logical(k); % get the mask within a group.
%         eval([' group_mask_g' num2str(i) '= group_mask;']);
     end
 
%     % in order to deal with the situation that some voxels in some group
%     % are 0, we need to get a common mask across groups
%    k=[]; 
%    k=logical(brain_mask);
%    for i=1:n_groups 
%       k=k.*eval(['group_mask_g' num2str(i)]);
%    end
%    Gp_mask=logical(k); % get the mask across groups.

     Gp_mask=logical(brain_mask);
 
                        
 %% an improved algorithm                      
                        
       for i=1:n_groups  % loops across the groups
           GP_V{i}=reshape(V_g{i},size(V_g{i},1)*size(V_g{i},2)*size(V_g{i},3),size(V_g{i},4));
       end          
       
       Gp_mask_tem=Gp_mask(:);
       size_Gp_mask=size(Gp_mask);
       clear Gp_mask
       fprintf('\n--- ICC calculation starts! Start timing.................\n')
       fprintf('\n--- It may take quite a long time, be patient...\n')
       tic
      
      r1=[]; p1=[]; %  LB1=[];  UB1=[];  F1=[];  df11=[];  df21=[];  
      r=zeros(size(Gp_mask_tem)); p=r; % LB=r; UB=r;  F=r; df1=r; df2=r; 
      
    %% find out all the voxels that are needed to be calculate ICC
      ids=find(Gp_mask_tem==1);
      clear Gp_mask_tem
      
%       N=[];  % merge n-group TCs into one matrix
%       for i=1:n_groups   
%           tem_Gp=eval(['Gp_sub' num2str(i) ''';']); % transpose the Gp_sub(i) 
%           N=[N eval('tem_Gp(:)')];          
%       end 

      n_voxels=size(ids,1);
      waitbar_4=round([0.1*n_voxels,0.3*n_voxels,0.6*n_voxels,0.9*n_voxels]);
      k=1;
      for j=1:n_voxels % deal with the calculation voxel by voxel
          
             x=ids(j); % loop within ids 
             M=[];
             for i=1:n_groups  
                 M=[M,GP_V{i}(x,:)'];
             end

             [r1, p1] = FG_ICC(M, deblank(type), alpha, r0);
            
             r(x)  = r1;
             p(x)  = p1;
             
           % eval(['LB(' num2str(x) ')  = LB1;']);
           % eval(['UB(' num2str(x) ')  = UB1;']);
           % eval(['F(' num2str(x) ')  = F1;']);
           % eval(['df1(' num2str(x) ')  = df11;']);
           % eval(['df2(' num2str(x) ')  = df21;']);  
           
          if j==waitbar_4(k)
              fprintf('--- %d / %d voxels are done......\n',j,n_voxels)
              k=k+1;
              if k>=4,k=4;end
          end
          
      end
          
      fprintf('\n--- ICC calculation is done!.................\n')
      total_t= toc; 
      fprintf('\n--- It takes totally %s mins to finish!!!\n',num2str(total_t/60))
      
                        
       r=reshape(r,size_Gp_mask);
       p=reshape(p,size_Gp_mask);  
  
  V=spm_vol(deblank(imgs_g{1}(1,:)));% read a piece cbf img
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
    
     V.fname=[root_dir  a  '_icc_r_value(alpha =' num2str(alpha)  ')_' type '.nii'];
     spm_write_vol(V,r);

     V.fname=[root_dir  a  '_icc_p_value(alpha =' num2str(alpha)  ')_' type '.nii'];
     spm_write_vol(V,p);
  

    r(find(p>alpha))=0; % find out all the voxels that have a sig. ICC-test
    V.fname=FG_check_and_rename_existed_file([root_dir  a  '_icc_r_value_sig(at_p=' num2str(alpha)  ')_' type '.nii']);
    spm_write_vol(V,r);
    
    r(find(p>0.01))=0; % find out all the voxels that have a sig. ICC-test
    V.fname=FG_check_and_rename_existed_file([root_dir  a  '_icc_r_value_sig(at_p=0.01)_' type '.nii']);
    spm_write_vol(V,r);
    
    
    r(find(p>0.001))=0; % find out all the voxels that have a sig. ICC-test
    V.fname=FG_check_and_rename_existed_file([root_dir  a  '_icc_r_value_sig(at_p=0.001)_' type '.nii']);
    spm_write_vol(V,r);
    
%  V.fname=FG_check_and_rename_existed_file([root_dir  a  '_icc_Globalmask(alpha =' num2str(alpha)  ')_' type '.img']);
%  spm_write_vol(V,Gp_mask);
  
fprintf('\n---------------------------All set!!!!!!!!!!---\n\n')