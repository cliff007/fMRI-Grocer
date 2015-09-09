function FG_img2zScore_img
%% this script based on SPM2/5/8	

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % files selcet   % start 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 % selcet the gray-matter img
 % [the gray-matter img's voxel size & img dimention should be the same as the cbf imgs that will be selected later]
  % selcet the cbf imgs that will be masked by the selceted gray-matter mask
  if strcmp(spm('ver',[],1),'SPM5')|strcmp(spm('ver',[],1),'SPM8')
       Filename = spm_select(inf,'any','Select the image to be read', [],pwd,'.*img$|.*nii$');
  else  
       Filename = spm_get(inf,'any','Select the image to be read'); 
  end
  
   if isempty(Filename)
      return
   end
  
  num=size(Filename,1);
  if isempty(Filename)
      return
  end

  if strcmp(spm('ver',[],1),'SPM5')|strcmp(spm('ver',[],1),'SPM8')
       mask = spm_select(1,'any','Select a mask to specify the area you want to deal with, or skip this step~', [],pwd,'.*img$|.*nii$');
  else  
       mask = spm_get(1,'any','Select a mask to specify the area you want to deal with, or skip this step~'); 
  end

  
  % define an test output
    h=questdlg('Do you want to display the normality-test result in command window?','Hi....','Yes','No','No') ;         

  
  
  % to convert img values into zscore, of course you should deal with only
  % the voxels within the mask
  
%             h_scale=questdlg('Do you want to scale the whole brain or just the regions within your mask?','Choose one ...','Whole original brain','Just within the mask','Just within the mask') ;
%             if isempty(h_scale)
%                 return
%             end  


 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % files selcet   % end %
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 % new: deal with 4D matrix to improve script performance 
  
    if isempty(mask)
        [Path,Name,Ext,Versn] = fileparts(Filename(1,:));
        V=spm_vol(deblank(Filename(1,:)));  
        dat1=ones(V.dim); % that means no mask is used
        clear V
        name1='no mask';
    else        
        V1=spm_vol(deblank(mask));
        dat1 = spm_read_vols(V1);   % read the mask img  
        [pathstr1, name1, ext1, versn1]=fileparts(mask);
    end 
 
    All_V=spm_vol(Filename);
    ALL_dat = spm_read_vols(All_V);
    
 
 %%%%
fprintf('\n-----calcultating........\n\n')

 for k=1:num,
        
    [Path,Name,Ext,Versn] = fileparts(Filename(k,:));
    V=spm_vol(deblank(Filename(k,:)));
    dat = spm_read_vols(V);   % read a img
        

    masked_img=dat.*dat1;   
    
    masked_img_filtered=masked_img;
    masked_img_filtered(find(isnan(masked_img_filtered)))=0; % set the NaN voxel values into zero
    
    total_voxels=V.dim(1)*V.dim(2)*V.dim(3);  % or total_voxels=size(dat,1)*size(dat,1)*size(dat,1)
    total_vaildvoxels=length(find(~isnan(masked_img(find(masked_img)))));% voxels number that is not NAN & not zero
        

       masked_vaild_values=[];
       masked_vaild_values=masked_img(find(dat1~=0));
       masked_vaild_values=masked_vaild_values(find(~isnan(masked_vaild_values)));
%       img_mean=mean(masked_vaild_values); % average all the values that is Non-Nan within the mask (include all vaild '0's if there is some)
        
    
% % %             % chi test of normal distribution
% % %             [h,p]=chi2gof(masked_vaild_values);
% % %             if h==0
% % %             fprintf('%s %s %s %1.0f   %1.5f \n','the value distribution of img ',[Name Ext],'is normal(h=0); [h,p] =',h,p)
% % %             else
% % %             fprintf('%s %s %s %1.0f   %1.5f \n','the value distribution of img ',[Name Ext],'is NOT normal(h=1); [h,p] =',h,p)
% % %             end

     if strcmp(h,'Yes')
 
        % [H, pValue, SWstatistic] = SWTEST(X, ALPHA, TAIL) test the sample normality 
         [h, p, SWstatistic] = FG_Shapiro_Wilk_W_test(masked_vaild_values, 0.05, 0);
            if h==0
                fprintf('%s %s %s %1.0f   %1.5f \n\n','the value distribution of img ',[Name Ext],'is normal(h=0); [h,p] =',h,p)
            elseif h==1
                fprintf('%s %s %s %1.0f   %1.5f \n\n','the value distribution of img ',[Name Ext],'is NOT normal(h=1); [h,p] =',h,p)
            end   
     end

       img_zScore=masked_img_filtered;
       img_zScore(find(img_zScore~=0)) = zscore(img_zScore(find(img_zScore~=0))); %% good method
       
       vo = V; 
       vo.fname=fullfile(Path, ['zScore_' spm_str_manip(Filename(k,:),'dt')]);
       vo=spm_write_vol(vo, img_zScore);
    
                    % chi test of normal distribution
                        %    [h,p]=chi2gof(img_zScore_vaild_values);
                        %    if h==0
                        %    fprintf('%s %s %s %1.0f   %1.5f \n\n','the value distribution of img ',['zScore_' spm_str_manip(Filename(k,:),'dt')],'is normal(h=0); [h,p] =',h,p)
                        %    else
                        %    fprintf('%s %s %s %1.0f   %1.5f \n\n','the value distribution of img ',['zScore_' spm_str_manip(Filename(k,:),'dt')],'is NOT normal(h=1); [h,p] =',h,p)
                        %    end
    if strcmp(h,'Yes')
        % [H, pValue, SWstatistic] = SWTEST(X, ALPHA, TAIL) test the sample normality 
         [h, p, SWstatistic] = FG_Shapiro_Wilk_W_test(img_zScore(find(img_zScore~=0)), 0.05, 0);
            if h==0
                fprintf('%s %s %s %1.0f   %1.5f \n\n','the value distribution of img ',['zScore_' spm_str_manip(Filename(k,:),'dt')],'is normal(h=0); [h,p] =',h,p)
            elseif h==1
                fprintf('%s %s %s %1.0f   %1.5f \n\n','the value distribution of img ',['zScore_' spm_str_manip(Filename(k,:),'dt')],'is NOT normal(h=1); [h,p] =',h,p)
            end
    end

 end;
 
fprintf('\n\n------img2zscore calculation done~~\n\n')
