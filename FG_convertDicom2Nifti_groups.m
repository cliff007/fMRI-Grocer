function FG_convertDicom2Nifti_groups
uiwait(msgbox('Please make sure that the pathes of the files you select have no space(s)!!','Attention...','modal'));
anyreturn=FG_modules_selection('','','','','r','g','fo');
if anyreturn, return;end

out_format = questdlg('Select a output file format...','Hi...','nii','img','nii') ;
DelorNo = questdlg('Do you want to delete original Dicom files?','Hi...','Del','No','No') ;
error_msg=[];

 for g=1:size(groups,1) 
    
    % assigning the subfolders of groups
    dirs=FG_module_assign_dirs(root_dir,dirs_tem,groups,g,folder_filter,h_folder,opts); 
     
   for j=1:size(dirs,1)
       
       % P = spm_select(Inf, 'image','Images to reset orientation of'); 
        dicom_tem = spm_select('FPList', [root_dir deblank(groups(g,:)) filesep deblank(dirs(j,:))],'.*'); 
        cd ([root_dir deblank(groups(g,:)) filesep deblank(dirs(j,:))])
        if isempty(dicom_tem)
            continue            
        elseif ~isdicom(deblank(dicom_tem(1,:)))  % if the first item is not dicom file, skip
            error_msg=strvcat(error_msg,['Non-Dicom file: ' deblank(dicom_tem(1,:))]);
            continue
        else
            try
                FG_convert_DICOM_to_NIFTI(dicom_tem,'',DelorNo,out_format) %% this is much more fast, but not error can be tracked
                                                                 %% it can handle whole volume missing problem, but may not for the slice missing problem  
            catch me
                error_msg=strvcat(error_msg,['Fail at dcm2nii.exe method: ' deblank(dicom_tem(1,:))]);
                me.message
                fprintf('\n*************** Something wrong using dcm2nii.exe commands...')
                fprintf('\n*************** Make sure to check the image under %s ...',deblank(all_subdirs_pth(j,:)))
                fprintf('\n*************** Now switch to use SPM commands...\n')
                
                try
                    FG_convert_DICOM_to_NIFTI_SPM(dicom_tem,out_format,DelorNo) %% cliff 2013.8.13 make a final choice
                catch me1
                    error_msg=strvcat(error_msg,['Fail at SPM method: ' deblank(dicom_tem(1,:))]);
                    me1.message
                    fprintf('\n*************** Something wrong using SPM commands...')
                    fprintf('\n*************** Make sure to check the image under %s ...',deblank(all_subdirs_pth(j,:)))
                    fprintf('\n*************** Now switch to use SPM commands...\n')
                    continue
                end
            end
        end
             
      fprintf('%s --- %s ',groups(g,:),dirs(j,:))  
      fprintf('\n ---Dicom conversion is done...\n')         
   end
 end
 
cd (root_dir)

if ~isempty(error_msg)
    fprintf('\n\n%s \n\n','-------Attention Please!') 
    for i=1:size(error_msg,1)
        fprintf('%s \n',error_msg(i,:))
    end
end

fprintf('\n%s \n','-----------All set~~')
    

