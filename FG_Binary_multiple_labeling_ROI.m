function FG_Binary_multiple_labeling_ROI
% label the mutiple_areas' ROI img into different an img in which different areas is marked in different nums. 
% this can be used to handle the mask img generated by rest_sliceviewer's  "save clusters" function
  if strcmp(spm('ver',[],1),'SPM5')|strcmp(spm('ver',[],1),'SPM8')
       Filename = spm_select(inf,'any','Select the image to be read', [],pwd,'.*img$|.*nii$');
  else  
       Filename = spm_get(inf,'any','Select the image to be read'); 
  end
 if isempty(Filename)
     return
 end
 
 [Path,b,c,d]=fileparts(deblank(Filename(1,:)));
 
 Filename=spm_str_manip(Filename,'dc');  % take use of the "spm_str_manip" function

     if size(Filename,1)==1   % in this condition, [spm_str_manip(spm_str_manip(Filename,'dh'),'dc')] can't get the group dirctories
       i=size(Filename,2); 
       success=0;
       for j=i:-1:1
           if Filename(j)==filesep
               success=1;
               break
           end
       end
       if success==1
           Filename=Filename(j+1:end);
       end
    end
 
 

 for i=1:size(Filename,1)
    V=spm_vol(deblank(Filename(i,:))); % 
    Vmat=spm_read_vols(V); % 
    
    Vmat=logical(Vmat);
    
    V.fname=fullfile(Path, ['Binary_' deblank(Filename(i,:))]);
    spm_write_vol(V,Vmat);
 end


fprintf(1,'\n\nbinaryzation of the multiple labeling imgs has done~~~\n\n')
