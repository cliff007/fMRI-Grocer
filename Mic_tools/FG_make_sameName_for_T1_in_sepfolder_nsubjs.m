function FG_make_sameName_for_T1_in_sepfolder_nsubjs

        anyreturn=FG_modules_selection('Select the root folder containing all the subject folders','Please select all subjects...','','^','r','g');
        if anyreturn, return;end
        
        t1_dir = spm_select(1,'dir','Select the separate folder containing T1 img under root folder of a subject', [],pwd);  
        [pth,path_name]=FG_sep_group_and_path(t1_dir);  
     
        
        for i=1:size(groups,1) 
            subj_folder=fullfile(root_dir,deblank(groups(i,:)),path_name);
            t1s=spm_select('FPList',subj_folder,'.*img$|.*nii$');
%             [tem,t1s]=FG_separate_files_into_name_and_path(t1s);
            
            
            for j=1:size(t1s,1)
               tmp_name=deblank(t1s(j,:));
               FG_simple_rename(tmp_name,['T1',tmp_name(1,end-3:end)]);
            end
            
        end
        
        fprintf('-------All T1 images under each seprated folder are renamed as t1.img or t1.nii............\n\n')
