    filename = spm_select(1,'image','Select an Nifti image', [],pwd);
    if FG_check_ifempty_return(filename), return; end
    tem=deblank(filename)
    a=FG_load_nii(tem(1:end-2));
    FG_view_nii(a);