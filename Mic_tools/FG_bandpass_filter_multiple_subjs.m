function FG_bandpass_filter_multiple_subjs

    anyreturn=FG_modules_enhanced_selection('','','','^.*img$|^.*nii$','r','g','fo','fi');
    if anyreturn, return;end
    

        prompt = {'Enter your scan TR:','Enter the low pass high-cutoff:','Enter the high pass low-cutoff:', ...
                  'Add Mean back to the images after filtering:'};
        dlg_title = 'Filter the images...';
        num_lines = 1;
        def = {'2','0.08','0.01','Yes'};
        answer = inputdlg(prompt,dlg_title,num_lines,def);
        ASamplePeriod=str2num(answer{1});
        ALowPass_HighCutoff=str2num(answer{2});
        AHighPass_LowCutoff=str2num(answer{3});
        AAddMeanBack=answer{4};
        AMaskFilename=1;  
        
        NewGroup_subfix=['_Filtered_TR' num2str(ASamplePeriod) '_BP' num2str(AHighPass_LowCutoff) '_' num2str(ALowPass_HighCutoff)];
   
for g=1:size(groups,1)
    NewGroup=fullfile(root_dir ,[deblank(groups(g,:)) NewGroup_subfix]);
    mkdir(NewGroup)
    % assigning the subfolders of groups
    dirs=FG_module_assign_dirs(root_dir,dirs_tem,groups,g,folder_filter,h_folder,opts); 
    
    for i=1:size(dirs,1)   
        
        % files reading     
        fun_imgs=FG_module_enhanced_read_funImgs(root_dir,groups,dirs,g,i,all_fun_imgs,file_filter,h_files,opts);      
        [a,b,c,d]=FG_separate_files_into_name_and_path(fun_imgs(1,:));
        ADataDir=a;
        FG_bandpass_filter(ADataDir,fun_imgs, ...
                                ASamplePeriod, ... 
                                ALowPass_HighCutoff, ... 
                                AHighPass_LowCutoff, ...
                                AAddMeanBack, ...
                                AMaskFilename);

    end
    movefile(fullfile(root_dir, deblank(groups(g,:)),'*filtered*'),NewGroup )
    fprintf ('\n.......File moving for group: %d is done!......', g)
end

fprintf ('\n.................. All the bandpass filterings are done!......\n')

