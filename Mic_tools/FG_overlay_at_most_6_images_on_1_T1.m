function FG_overlay_at_most_6_images_on_1_T1
t1 = spm_select(1,'any','Select one base-image(e.g. T1)',[],pwd,'.*nii$|.*img$');
t1 = spm_vol(t1);
spm_orthviews('Image',t1)

spm_orthviews('AddBlobs',handle,XYZ,Z,mat,name)