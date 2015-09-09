function FG_clear_files_under_selected_folders_for_RE_Estimation
currdir=pwd;
dirs = spm_select(inf,'dir','Select all output folders containing SPM.mat files', [],pwd,'.*'); 

choice= questdlg('Are you sure to clear the potenial img/hdr/nii/mat/txt files under the selected folders?','Please confirm...','Yes','No','No') ;
if strcmp(choice,'Yes')
   for j=1:size(dirs,1)
    tem=deblank(dirs(j,:));
    tem=tem(1:end-1);
    cd (tem)
    delete *.mat
    delete *.img
    delete *.hdr
    delete *.nii
    delete *.ps
    delete *.txt
   end
else
   return
end

cd (currdir)
fprintf('\n=== All img/hdr/nii/mat/txt files under the selected folders are deleted...\n')