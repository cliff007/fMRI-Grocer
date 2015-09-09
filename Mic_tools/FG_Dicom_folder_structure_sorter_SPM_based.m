function FG_Dicom_folder_structure_sorter_SPM_based

    imgs = spm_select(inf,'.*','Select all the dicom images', [],pwd,'.*');
    if isempty(imgs),return,end
    root_dir=FG_sep_group_and_path(deblank(imgs(1,:)));
%     root_dir = spm_select(1,'dir','Select an ouput directory', [],pwd,'.*');
    if isempty(root_dir),return,end
    Method=questdlg('Plese select a suggested method in sorting DICOM images','Soring method...', 'Protocol Name','./PatientID/Protocol Name','No Directory','Protocol Name');
    nifti=questdlg('Plese select an output image format','Output image format...', 'nii','img','nii');
    pause(0.5)
    switch Method
        case 'Protocol Name'
            mtd = 'patid';
        case './PatientID/Protocol Name'
            mtd = 'series';
        case 'No Directory'
            mtd = 'flat';
    end
            
            
            
    write_name=FG_check_and_rename_existed_file(fullfile([root_dir,'Dicom_folder_structure_sorter_job.m']));

    % build the batch header
    dlmwrite(write_name,'%-----------------------------------------------------------------------', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name, '% Job configuration created by cfg_util (rev $Rev: 3944 $)', '-append', 'delimiter', '', 'newline','pc');
    dlmwrite(write_name,'%-----------------------------------------------------------------------', '-append', 'delimiter', '', 'newline','pc'); 
    
    dlmwrite(write_name,'matlabbatch{1}.spm.util.dicom.data = {', '-append', 'delimiter', '', 'newline','pc'); 
    for i=1:size(imgs,1)
        dlmwrite(write_name,['''' deblank(imgs(i,:)) ''''], '-append', 'delimiter', '', 'newline','pc'); 
    end
    
    
    dlmwrite(write_name,'};', '-append', 'delimiter', '', 'newline','pc');
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.util.dicom.root = ''',mtd,''';'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.util.dicom.outdir = {''', root_dir, '''};'), '-append', 'delimiter', '', 'newline','pc');
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.util.dicom.convopts.format = ''',nifti,''';'), '-append', 'delimiter', '', 'newline','pc');
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.util.dicom.convopts.icedims = 0;'), '-append', 'delimiter', '', 'newline','pc');
    
    spm_jobman('run',deblank(write_name))
    delete (write_name)
