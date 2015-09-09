% function [] = Global_Norm(Filename)
%  
% This MATLAB function is to cal the relative signal intensity of each voxel after global normalization.
% gm_sig = raw_sig*100/globalCBF

 function FG_grandmean_scale_CBF_in_ROI(Filename)

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % files selcet   % start 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % selcet the gray-matter img
 % [the gray-matter img's voxel size & img dimention should be the same as the cbf imgs that will be selected later]
  % selcet the cbf imgs that will be masked by the selceted gray-matter mask
  if strcmp(spm('ver',[],1),'SPM5')||strcmp(spm('ver',[],1),'SPM8')
       Filename = spm_select(Inf,'any','Select images to be read', [],pwd,'.*img$|.*nii$');
  else  
       Filename = spm_get(Inf,'any','Select images to be read'); 
  end
  
   if isempty(Filename)
      return
   end 
  num=size(Filename,1);
  
  if strcmp(spm('ver',[],1),'SPM5')||strcmp(spm('ver',[],1),'SPM8')
       Gray = spm_select(1,'any','Select a mask used to calculate the global mean(e.g. Gray matter)', [],pwd,'.*img$|.*nii$');
  else  
       Gray = spm_get(1,'any','Select a mask img'); 
  end

    if isempty(Gray)
      return
    end 
    
  
   
  VG = spm_vol(deblank(Gray));  
  maskdat = logical(spm_read_vols(VG));% this gray-matter image is a gray image thate can be used as a mask
  
  
  h_scale=questdlg('Do you want to scale the whole brain or just the regions within your mask?','Choose one ...','Whole original brain','Just within the mask','Just within the mask') ;
    if isempty(h_scale)
        return
    end  

  
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % files selcet   % end %
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  global_inten = zeros(num,2);  % initialize the Nx2 global intensity matrix
  
 %%%% voxel by voxel caculation %%%
  for k=1:num,
        [Path,Name,Ext,Versn] = fileparts(Filename(k,:));
        V=spm_vol(deblank(Filename(k,:)));
        dat = spm_read_vols(V);   % read a piece cbf img
        global_inten(k, 1) = spm_global(V); % get the original cbf img's global mean cbf value using "spm_global()" based on SPM
        
      % caculate the gray-matter's global mean cbf
        graydat = dat.*maskdat; % create the cbf image masked by the gray-matter image 
      %  global_inten(k, 2)  =   sum(sum(sum(graydat)))/sum(sum(sum(graydat>0))); %  gray-matter's global mean cbf caculating
        
       % sum the voxel cbf values after excluding the "Nan" value voxels to
       % caculate the real global cbf value
       %%%%% global_inten(k, 2)  =   sum(graydat(find(~isnan(graydat))))/sum(sum(sum(graydat>0))); 
        
% % % %         graydat_vaild_values=[];
% % % %         for i=1:V.dim(1)*V.dim(2)*V.dim(3)
% % % %             if maskdat(i)~=0 & ~isnan(graydat(i)) % "maskdat(i)~=0 or maskdat(i)==1(but in this way there are sth wrong)" is to ensure that all the values are limited within the mask; it is wrong to use "graydat(i)~=0"
% % % %                 graydat_vaild_values=[graydat_vaild_values;graydat(i)];  % the total_vaildvoxels must be equal the length(masked_vaild_values)
% % % %             end
% % % %         end
% % % %         global_inten(k, 2)=mean(graydat_vaild_values);      
        
        
       graydat_vaild_values=[];
       graydat_vaild_values=graydat(find(maskdat~=0));
       graydat_vaild_values=graydat_vaild_values(find(~isnan(graydat_vaild_values)));
       global_inten(k, 2)=mean(graydat_vaild_values); % average all the values that is Non-Nan within the mask (include all vaild '0's if there is some) 
        

  %      for i=1:V.dim(3)
  %         gcdat(:,:,i) = (dat(:,:,i)-global_inten(k, 2))*100/global_inten(k, 2);         % like (mALFF-1)
  %      end;
  

  
  
  % define the [absolute threshold] range
   %   abs_lowthreshold = 10;
      abs_highthreshold = 130;
   %  scaled_img = scaled_img.*(graydat > abs_lowthreshold).*(graydat < abs_highthreshold); %   
   
   
switch h_scale
    case 'Whole original brain'
% scale the whole brain: be careful, the gray matter mask just used to
% calculate the global mean, and we use this mean value to scale the whole brain
        scaled_img=zeros(size(dat));  
        dat(find(isnan(dat)))=0; % first reset all the NaN value into 0
        originalCBF_mask=logical(dat); % used to define the original CBF regions
        for i=1:V.dim(1)*V.dim(2)*V.dim(3)
            if originalCBF_mask(i)~=0 & ~isnan(dat(i)) % "maskdat(i)==1" is to ensure that all the values are limited within the mask; it is wrong to use "graydat(i)~=0"
                scaled_img(i) = dat(i)*100/global_inten(k, 2);    % like (mALFF-1)
            end
        end

    case 'Just within the mask'    
        scaled_img=zeros(size(dat));          
        for i=1:V.dim(1)*V.dim(2)*V.dim(3)  % we use gray matter mask to filter voxels having low value, and we still need to filter out the high value outliers
            if maskdat(i)~=0 & ~isnan(dat(i))  & dat(i)<=abs_highthreshold % "maskdat(i)==1" is to ensure that all the values are limited within the mask; it is wrong to use "graydat(i)~=0"
                scaled_img(i) = dat(i)*100/global_inten(k, 2);    % like (mALFF-1)
            end
        end  
end
     


       vo = V; 
       vo.fname=fullfile(Path, ['scaled_' spm_str_manip(Filename(k,:),'dt')]);           %%%%%%%%%  spm_str_manip() is a quite useful funtion~~~
       vo=spm_write_vol(vo, scaled_img);

 end;

% save  globalCBF global_inten; 
fprintf('%s \n','---------Decentering is done~~')
 


