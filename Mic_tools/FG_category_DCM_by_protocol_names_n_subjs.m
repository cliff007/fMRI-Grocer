function FG_category_DCM_by_protocol_names_n_subjs

clc
h=questdlg('**. It is going to category all DICOM-images of each subject into separate protocol-name folders, are you sure to continue?','Dicom sorting....','Yes','Skip','Skip') ;

switch h
    case 'Yes'
        fprintf('\n----Running...............................\n')
        anyreturn=FG_modules_selection('Select the root folder containing all the subject folders','Please select all subjects...','','^','r','g');
        if anyreturn, return;end
        
        for i=1:size(groups,1) 
%             [all_files,all_cell_files]=FG_list_all_files(deblank(groups(i,:)),'**','*');            

            subj_folder=fullfile(root_dir,deblank(groups(i,:)));
            all_dcm=FG_list_one_level_files(subj_folder,'*.*');
            if ~isempty(all_dcm)
                FG_category_DCM_by_protocol_names(all_dcm);
            end            
        end
        
        fprintf('-------Dicom sorting is done............\n\n')
    case 'Skip'
        fprintf('------Skip the Dicom sorting..............\n\n')
end
        
