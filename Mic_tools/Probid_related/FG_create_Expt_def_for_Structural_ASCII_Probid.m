function FG_create_Expt_def_for_Structural_ASCII_Probid

clear Expt_def
% initiate vars
defaults = PR_get_defaults();
Expt_def.Probid_ver=defaults.probid_version;
Expt_def.mask= 'auto';
Expt_def.n_tasks=1;
Expt_def.n_scans_s=1;  % number of repetitions of each task (= 1 for structural)


% select the modality for Probid
modalities = spm_input('Select Probid Type', '+1', 'm',['Structural | ASCII Text'], [1 2], 1); 
switch modalities
    case 1
        Expt_def.modality='struc';
        Expt_def.tasks{1}.name='STRUCT';
        file_filter='.*img$|.*nii$';
    case 2
        Expt_def.modality='ascii';
        file_filter='.*txt$';
end

%% 
    prompt = {'How many groups of subject?','How many subjects for each group (Each group should have the same number of subjects)'};
    dlg_title = 'Paras...';
    num_lines = 1;
    def = {'2','18'};
    paras = inputdlg(prompt,dlg_title,num_lines,def);    

    Expt_def.n_groups=str2num(paras{1});
    Expt_def.n_subjects=str2num(paras{2});
    
    groupnames=FG_inputdlg_selfdefined(Expt_def.n_groups,'--------------Please enter the name of group ','Group names...');
    for i=1:Expt_def.n_groups
       Expt_def.groups{i}.name=groupnames{i}; 
    end
    
%     for i=1:Expt_def.n_groups
%         for j=1:Expt_def.n_subjects
%             if j==1 && i==1
%                 pth=pwd;
%             else
%                 pth=FG_sep_group_and_path(allfiles(1,:));
%             end            
%             allfiles=spm_select(Expt_def.n_scans_s,'any',['Select files for Subject [ ' num2str(j) ' ] in Group = ' groupnames{i} ' ='], [],pth,'.*img$|.*nii$'); 
%             if FG_check_ifempty_return(allfiles),return,end
%             Expt_def.groups{i}.subjects{j}.data_files={allfiles};
%             
%         end
%     end
%     
    
    for i=1:Expt_def.n_groups
        if i==1
            pth=pwd;
        else
            pth=FG_sep_group_and_path(allfiles(1,:));
        end
        allfiles=spm_select(Expt_def.n_subjects,'any',['Select files of ' num2str(Expt_def.n_subjects) ' Subject in Group = ' groupnames{i} ' ='], [],pth, file_filter);
        if FG_check_ifempty_return(allfiles),return,end
        for j=1:Expt_def.n_subjects              
            Expt_def.groups{i}.subjects{j}.data_files={deblank(allfiles(j,:))};
        end
    end
    
    if strcmp(Expt_def.modality,'struc')
        % select an explicit mask
        em = spm_select(1,'any','Select an explicit mask (or you can just close the window if you don''t want this)', [],pwd,'.*img$|.*nii$');
        if ~isempty(em)
            Expt_def.mask.filename=em;        
    %         [voxel_mask, raw_mask, header]=PR_load_mask(Expt_def.mask.filename);
    % %         Expt_def.mask.voxel_mask = voxel_mask;
    % %         Expt_def.mask.raw_mask = raw_mask;
    % %         Expt_def.mask.mask_header = header;
        end   
    end
    
    root_dir_tem = spm_select(1,'dir','Select a root folder to store outputs', [],pwd);    
    root_dir=fullfile(root_dir_tem,'Expt_dir');
    mkdir(root_dir);
    mkdir(fullfile(root_dir_tem,'Result_dir'))   
     
    
    writename=fullfile(root_dir,'Expt_def.mat');
%     writename=FG_check_and_rename_existed_file(fullfile(root_dir,'Expt_def.mat'));
    save(writename,'Expt_def');


fprintf('\n==== Expt_def.mat file is created under %s\n',root_dir)

