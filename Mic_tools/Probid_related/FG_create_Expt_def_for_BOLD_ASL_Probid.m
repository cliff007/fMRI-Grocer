function FG_create_Expt_def_for_BOLD_ASL_Probid

clear Expt_def
% initiate vars
defaults = PR_get_defaults();
Expt_def.Probid_ver=defaults.probid_version;
Expt_def.mask='auto';

% select the modality for Probid
modalities = spm_input('Select Probid Type', '+1', 'm',['BOLD Timeseries| BOLD GLM Coefficients | BOLD Spatiotemporal| ASL/Perfusion'], [1 2 3 4], 1); 
switch modalities
    case 1
        Expt_def.modality='times';
    case 2
        Expt_def.modality='glmcf';
    case 3
        Expt_def.modality='spatt';
    case 4
        Expt_def.modality='aslpf';
end

%% 
    prompt = {'How many groups of subject?', ...
              'How many subjects for each group (Each group should have the same number of subjects)', ...
              'How many task in the scans', ...
              'How many repetitions of each task (blocks of each task in block-design OR number of events for event-related design)', ...
              'TR (in MilliSecnds(ms), e.g. 2000)' ...
              };
    dlg_title = 'Paras...';
    num_lines = 1;
    def = {'2','24','1','1','8000'};
    paras = inputdlg(prompt,dlg_title,num_lines,def);    
    
    Expt_def.n_groups=str2num(paras{1});
    Expt_def.n_subjects=str2num(paras{2});
    Expt_def.n_tasks=str2num(paras{3});
    Expt_def.n_scans_s=str2num(paras{4}); % number of repetitions of each task (= 1 for structural)
    Expt_def.TR=str2num(paras{5});  % specify in milliseconds, which is used to calculate the shift for the haemodynamic delay: delay = 3 / (TR/1000) 
%     hrf_delay=round(3 / (Expt_def.TR/1000));
    hrf_delay=floor(3/(Expt_def.TR/1000)); % according to PR_preproc_functional.m
    
    groupnames=FG_inputdlg_selfdefined(Expt_def.n_groups,'--------------Please enter the name of group ','Group names...');
    for i=1:Expt_def.n_groups
       Expt_def.groups{1,i}.name=groupnames{i}; 
    end
    
    tasknames=FG_inputdlg_selfdefined(Expt_def.n_tasks,'--------------Please enter the name of task ','Task names...');
    for i=1:Expt_def.n_tasks
       Expt_def.tasks{1,i}.name=tasknames{i}; 
    end
    
    % load the onset.mat files that is same for the scans of each subject 
   uiwait(warndlg('Next select the onset files and the onset duration for the scans of tasks of each subject. Both of the onset and duration''s unit should be "TR" rather than "Second"! Moreover, the onset.mat file should contain an exact "onset" variable, and the first image is corresponding to timepoit 1 rather than 0!','!! Warning !!','modal'));
   onsetfiles=spm_select(Expt_def.n_tasks,'any',['Select ' num2str(Expt_def.n_tasks) ' .mat onset-files in which "onset" variable is contained for the scans of each subject'], [],pwd,'.*mat$'); 
   onset_dur_weight = inputdlg('How many "TR" for the block or event labed by each onset (total TR-based length)','Onset duration...',1,{'1'});   
   onset_dur  = str2num(onset_dur_weight{1}) * ones(1,Expt_def.n_scans_s);
    
   for t=1:Expt_def.n_tasks
        tem=load(onsetfiles(t,:));
        onsets{t}=tem.onset; 
        if size(onsets{t},2)~=Expt_def.n_tasks
           fprintf('\n==== The onset num is different from the task or event number specified in the model! Please check it out!')
           return
        end
    end
    

    
   
   % select the image data
    % select folders and specify file filter
        groups=spm_select(Expt_def.n_groups,'dir',['Please select the root folder of ' num2str(Expt_def.n_groups) ' targeted groups'], [],pwd);
    % specify a file filter
        prompt = {'Specify a file filter(You should use asterrisk wildcard, e.g., ^,$,*,):'};
        num_lines = 1;
        def = {'^wsr.*img$|^wsr.*nii$'};
        dlg_title='file filter...';
        file_filter = inputdlg(prompt,dlg_title,num_lines,def);
        if FG_check_ifempty_return(file_filter), return; end
        file_filter =file_filter{1}; 
    % get the subdirs across sessions
        for g=1:Expt_def.n_groups % Attention: groups is the sessions here
            % assigning the subfolders of groups
            dirs{g}=spm_select(Expt_def.n_subjects,'dir',['Please select the subject folders of ' num2str(g) ' group: ' groupnames{g}], [],deblank(groups(g,:)));
            dir_n=size(dirs{g},1);
            if (dir_n-Expt_def.n_subjects)~=0 % judge the subject folders across sessions
                fprintf('\n-----No enough subject folders were selected! Please check it out first!\n')
                return
            end
        end
        
  % read the files  
    for g = 1:Expt_def.n_groups
        for s = 1:Expt_def.n_subjects
            fun_imgs= spm_select('FPList',deblank(dirs{g}(s,:)),file_filter);
            len_fun_imgs(g,s)=size(fun_imgs,1); % record the image number of the subject in this group
            Expt_def.groups{g}.subjects{s}.data_files = FG_convert_strmat_2_cell_basedon_row(fun_imgs);
        end
    end
    
    %% assign the the final onsets
    for g = 1:Expt_def.n_groups
        for s = 1:Expt_def.n_subjects
            for t = 1:Expt_def.n_tasks
              %% exclude the onsets that will be out of the image time
              %% series after applying the "hrf_delay" which will be
              %% implemented automatically in BOLD timeseries modality
                if size(onsets{t},2)>1 && strcmp(Expt_def.modality,'times')
                    tem=onsets{t}+ hrf_delay;
                    tem(tem>len_fun_imgs(g,s))=[];
                    onsets{t}=tem -hrf_delay;
                end
                    Expt_def.groups{g}.subjects{s}.tasks{t}.onsets = onsets{t};
                    Expt_def.groups{g}.subjects{s}.tasks{t}.lengths = onset_dur;
            end
        end
    end
    
    % select an explicit mask
    em = spm_select(1,'any','Select an explicit mask (or you can just close the window if you don''t want this)', [],pwd,'.*img$|.*nii$');
    if ~isempty(em)
        Expt_def.mask.filename=em;        
%         [voxel_mask, raw_mask, header]=PR_load_mask(Expt_def.mask.filename);
% %         Expt_def.mask.voxel_mask = voxel_mask;
% %         Expt_def.mask.raw_mask = raw_mask;
% %         Expt_def.mask.mask_header = header;
    end        
    
    root_dir_tem = spm_select(1,'dir','Select a root folder to store outputs', [],pwd);    
    root_dir=fullfile(root_dir_tem,'Expt_dir');
    mkdir(root_dir);
    mkdir(fullfile(root_dir_tem,'Result_dir'))
    
  
    
    writename=fullfile(root_dir,'Expt_def.mat');
    % writename=FG_check_and_rename_existed_file(fullfile(root_dir,'Expt_def.mat'));
    save(writename,'Expt_def');
    

fprintf('\n==== Expt_def.mat file is created under %s\n',root_dir)

