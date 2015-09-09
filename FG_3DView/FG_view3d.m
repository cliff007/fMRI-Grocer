function FG_view3d
 file = spm_select(1,'.img|.nii','Select the folder that fMRI_stduy root folder', [],pwd);
   if isempty(file)
      return
   end 
 Vmat=spm_vol(deblank(file)); 
 V = spm_read_vols(Vmat); 
 imlook3d(V);
