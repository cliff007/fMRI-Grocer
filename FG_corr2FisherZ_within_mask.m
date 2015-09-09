function corr2FisherZ_within_mask
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
  


  if strcmp(spm('ver',[],1),'SPM5')|strcmp(spm('ver',[],1),'SPM8')
       mask = spm_select(1,'any','Select a mask to specify the area you want to deal with, or skip this step~', [],pwd,'.*img$|.*nii$');
  else  
       mask = spm_get(1,'any','Select a mask to specify the area you want to deal with, or skip this step~'); 
  end
  
   h_scale=questdlg('Do you want to scale the whole brain or just the regions within your mask?','Choose one ...','Whole original brain','Just within the mask','Just within the mask') ;
    if isempty(h_scale)
        return
    end  
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % files selcet   % end %
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%


 for k=1:num,
        
    [Path,Name,Ext,Versn] = fileparts(Filename(k,:));
    V=spm_vol(deblank(Filename(k,:)));
    dat = spm_read_vols(V);   % read a img
        

    if isempty(mask)
        dat1=ones(size(dat)); % that means no mask is used
        name1='no mask';
    else        
        V1=spm_vol(deblank(mask));
        dat1 = logical(spm_read_vols(V1));   % read the mask img  
        [pathstr1, name1, ext1, versn1]=fileparts(mask);
    end
    
    masked_img=dat.*dat1;   
    
    
    total_voxels=V.dim(1)*V.dim(2)*V.dim(3);  % or total_voxels=size(dat,1)*size(dat,1)*size(dat,1)

    

     switch h_scale
        case 'Whole original brain'  
            
            img_zScore=zeros(size(masked_img)); % the final imgs will only have vaild Non-Nan value within the mask (include all vaild '0's if there is some) 
            dat(find(isnan(dat)))=0; % first reset all the NaN value into 0
            originalCBF_mask=logical(dat); % used to define the original CBF regions
            
            for j=1:total_voxels
                if originalCBF_mask~=0 & ~isnan(dat(j))
                    img_zScore(j) =0.5 * log((1 +masked_img(j))./(1- masked_img(j)));  % Fisher's Z transformation;
                end
            end;
        
        case 'Just within the mask' 
            img_zScore=zeros(size(masked_img)); % the final imgs will only have vaild Non-Nan value within the mask (include all vaild '0's if there is some) 
            for j=1:total_voxels
                if dat1(j)~=0 & ~isnan(dat(j))
                    img_zScore(j) =0.5 * log((1 +masked_img(j))./(1- masked_img(j)));  % Fisher's Z transformation;
                end
            end;
     end
    
    
    
    
       vo = V; 
       vo.fname=fullfile(Path, ['FisherZ_' spm_str_manip(Filename(k,:),'dt')]);
       vo=spm_write_vol(vo, img_zScore);
    

 end;
 
fprintf('%s \n\n','caculationg done~~')
