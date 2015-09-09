
function FG_1st_level_gen

% Timing parameters for 1st-level
prompt = {'Units for design (scans or seconds):','Interscan interval: ','Microtime resolution: ','Microtime onset: ','What is the duration for the onsets (0 for even-related design, or some other predefined value)?' ,...
            '*** How many Sessions for each subject? ', ...
            '*** How many Conditions under each session (It assumes that the number of condiditons is same across sessions)?' ,...
            };
dlg_title = 'Timing parameters for 1st-level...';
num_lines = 1;
def = {'scans','2.56','16','1','0','4','4'};
timing_paras = inputdlg(prompt,dlg_title,num_lines,def,'on');
session_n=str2num(timing_paras{6});
condition_n=str2num(timing_paras{7});
PoD_idx=FG_inputdlg_selfdefined(condition_n,'(1 for Yes, 0 for No)Is there a parameter modulation settting for condition ','Para-modulation SetUp...',0);
PoD_idx=str2num(cell2mat(PoD_idx)); PoD_n=length(find(PoD_idx));

if session_n>1
    cond_same=questdlg('Are the condition-names same across sessions? If they are, it means you just need to enter the condition names once for all sessions; Otherwise, you need to enter condition names session by session','Hi....','Yes','No','Yes') ;
    var_same=questdlg('Are the variable-names same across sessions? If they are, it means you just need to enter the variable names once for all sessions; Otherwise, you need to enter variable names session by session','Hi....','Yes','No','Yes') ;
    if strcmp(var_same,'Yes')
       onset_same=questdlg('Are the onset files same across each session? If they are, it means you just need to select onset files once for all sessions; Otherwise, you need to select onset files session by session','Hi....','Yes','No','Yes') ;
    else
       onset_same='No'; 
    end
elseif session_n==1
    cond_same='Yes';
    var_same='Yes';
elseif session_n<1
    fprintf('\n-----The Session number should be not smaller than 1! Please check it out first!\n')
    return
end
if FG_check_ifempty_return(var_same),return,end

% h_RC=questdlg('Is your onset variable a column-vector or a row-vector?','Hi....','column','row','column') ; % judge it automically below instead



% Specify the condition names & variable-names and potential modulation-parameter names & variable-names
for i=1:session_n
    if strcmpi(cond_same,'Yes')
        if i==1 % if same, only setup once, and then replicate the settings for all other sessions
            condition_names{i}=FG_inputdlg_selfdefined(condition_n,'--- Please specify a condition-name for Condition---------- ','Condition-names SetUp...','condition_Name');
            if FG_check_ifempty_return(condition_names{i}),return,end
            def = repmat({'onsets_'},1,size(condition_names{i},1));
        else
            condition_names{i}=condition_names{1} ;
        end
    else        
        condition_names{i}=FG_inputdlg_selfdefined(condition_n,'--- Please specify a condition-name for Condition---------- ','Condition-names SetUp...','condition_Name');
        if FG_check_ifempty_return(condition_names{i}),return,end
        def = repmat({'onsets_'},1,size(condition_names{i},1));
    end
    
    
    if strcmpi(var_same,'Yes')
        if i==1 % if same, only setup once, and then replicate the settings for all other sessions
            condition_var_names{i}=inputdlg(FG_add_characters_at_the_start(condition_names{i},'Please Enter the onset variable-name for the condition:  '),'Condition variable-name in onset files for all sessions ',1,def,'on'); % only one-time entering
            if FG_check_ifempty_return(condition_var_names{i}),return,end
        else
            condition_var_names{i}=condition_var_names{1} ;
        end
    else
        condition_var_names{i}=inputdlg(FG_add_characters_at_the_start(condition_names{i},'Please Enter the onset variable-name for the condition:  '),['Condition variable-name in onset files for session ',num2str(i)],1,def,'on'); 
        if FG_check_ifempty_return(condition_var_names{i}),return,end
    end
    
       
    if PoD_n>0
        prompt={};
        def={};
        for j=1:size(PoD_idx,1)
            if PoD_idx(j)==1
                prompt = [prompt, deblank(condition_names{i}(j))];
                def = [def,'PoD_var'];
            elseif PoD_idx(j)==0
                prompt = [prompt, 'No need to set up for this condiditon'];
                def = [def,'---'];   
            end
        end
        PoD_names{i}=inputdlg(prompt,'Specify a modulation-parameter name for selected Conditions',1,def,'on');
        if FG_check_ifempty_return(PoD_names{i}),return,end
        if strcmpi(var_same,'Yes') 
            if i==1 % if same, only setup once, and then replicate the settings for all other sessions
                PoD_var_names{i}=inputdlg(PoD_names{i},'(leave the  "---" rows blank)Specify variable-name that would imoprted from onset files for each modulation-parameter for all sessions',1,def,'on');
                if FG_check_ifempty_return(PoD_var_names{i}),return,end
            else
                PoD_var_names{i}=PoD_var_names{1} ;
            end
        else
            PoD_var_names{i}=inputdlg(PoD_names{i},['(leave the  "---" rows blank)Specify variable-name that would imoprted from onset files for each modulation-parameter for session ',num2str(i)],1,def,'on');
            if FG_check_ifempty_return(PoD_var_names{i}),return,end
        end
        clear def
    end
end


% select folders and specify file filter
    groups=spm_select(session_n,'dir',['Select ' num2str(session_n) ' groups (sessions) folders'], [],pwd);
% specify a file filter
    prompt = {'Specify a file filter(You should use asterrisk wildcard, e.g., ^,$,*,):'};
    num_lines = 1;
    def = {'^wsr.*img$|^wsr.*nii$'};
    dlg_title='file filter...';
    file_filter = inputdlg(prompt,dlg_title,num_lines,def);
    if FG_check_ifempty_return(file_filter), return; end
    file_filter =file_filter{1}; 
% get the subdirs across sessions
    for g=1:session_n % Attention: groups is the sessions here
        % assigning the subfolders of groups
        [dirs{g},full_dirs{g}]=FG_readsubfolders(deblank(groups(g,:)));
        dir_n(g)=size(dirs{g},1);
    end
    if prod(dir_n-mean(dir_n))~=0 % judge the subject folders across sessions
        fprintf('\n-----The subject folders across groups(sessions) is different! Please check it out first!\n')
        return
    else
        subj_n=dir_n(1);
    end    
% select the files of onsets
    if strcmpi(var_same,'Yes')  && strcmpi(onset_same,'Yes') %%%%%%%%%% the variable in the .mat files should be column-variable rather than row-variable
        onset_files{1} = spm_select(subj_n,'any',['Select ' num2str(subj_n) ' oneset-files for the subjects in all sessions '], [],pwd,'.*mat$');
        if FG_check_ifempty_return(onset_files{1}), return,end
    else
        for g=1:session_n
            onset_files{g} = spm_select(subj_n,'any',['Select ' num2str(subj_n) ' oneset-files for the subjects in session ' num2str(g)], [],pwd,'.*mat$');
            if FG_check_ifempty_return(onset_files{g}), return,end
            if size(onset_files{g},1)~=subj_n, 
                fprintf('\n-----The number of onset files is differernt from subject number! Please check it out first!\n');
                return
            end
        end
    end    
    
% % select the motion regressor under the subject folder: rp*.txt  
  h_rp=questdlg('Do you want to regress out the 6 head-motion index in the 1st level model?','Regress out head-motion....','Yes','No','Yes') ;
% select an explicit mask
    em = spm_select(1,'any','Select an explicit mask (or you can just close the window if you don''t want this)', [],pwd,'.*img$|.*nii$');
% create the output folder automatically
    root_dir = [FG_del_filesep_at_the_end(deblank(groups(1,:))) '_related_1st_level_GLM'];
    mkdir (root_dir)    
%     root_dir = spm_select(1,'dir','Select a folder to store all the 1st-level GLM results', [],pwd);



%%%%%% main program
for i_subj=1:subj_n
    if strcmpi(var_same,'Yes') && strcmpi(onset_same,'Yes')
        onsets=load(deblank(onset_files{1}(i_subj,:)));
    else
        for g=1:session_n
            onsets{g}=load(deblank(onset_files{g}(i_subj,:)));                
        end
    end
    
    root_dir1=fullfile(root_dir,[deblank(dirs{1}{i_subj}) '_1st_GLM']);
    mkdir (root_dir1)
    write_name=strcat(root_dir,filesep,'level_1st_analysis_for_', deblank(dirs{1}{i_subj}), '_', timing_paras{6}, '_session_', timing_paras{7},'_condition_job.m');

    % build the batch header
    dlmwrite(write_name,'%-----------------------------------------------------------------------', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name, '% Job configuration created by cfg_util (rev $Rev: 3944 $)', '-append', 'delimiter', '', 'newline','pc');
    dlmwrite(write_name,'%-----------------------------------------------------------------------', '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.fmri_spec.dir = {''',root_dir1,'''};'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.fmri_spec.timing.units = ''',timing_paras{1},''';'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.fmri_spec.timing.RT = ',timing_paras{2},';'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = ',timing_paras{3},';'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = ',timing_paras{4},';'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,'%%%%', '-append', 'delimiter', '', 'newline','pc'); 


    for i_sess=1:session_n
        fun_imgs= spm_select('FPList',deblank(full_dirs{i_sess}{i_subj}),file_filter);
        %write down the image files
        dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.fmri_spec.sess(', num2str(i_sess) ,').scans = {'), '-append', 'delimiter', '', 'newline','pc'); 
        for k=1:size(fun_imgs,1)
            dlmwrite(write_name,strcat('''',deblank(fun_imgs(k,:)), ',1'''), '-append', 'delimiter', '', 'newline','pc');
        end
        dlmwrite(write_name,strcat('};'), '-append', 'delimiter', '', 'newline','pc'); 

        for i_con=1:condition_n
            dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.fmri_spec.sess(', num2str(i_sess) ,').cond(', num2str(i_con) ,').name = ''',deblank(condition_names{i_sess}(i_con)) ,''';'),'-append', 'delimiter', '', 'newline','pc'); 
            tem_onset=eval(['onsets{' num2str(i_sess) '}.' condition_var_names{i_sess}{i_con} ]); % pre-read the onset variable
            if size(tem_onset,1)>size(tem_onset,2) && size(tem_onset,2)==1 % judge whether it is a column vector
                tem_onset=tem_onset'; % CHANGE it into row vector
            end  
            
            dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.fmri_spec.sess(', num2str(i_sess) ,').cond(', num2str(i_con) ,').onset = [',num2str(tem_onset) ,'];'),'-append', 'delimiter', '', 'newline','pc');  
            dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.fmri_spec.sess(', num2str(i_sess) ,').cond(', num2str(i_con) ,').duration =', timing_paras{5} ,';'), '-append', 'delimiter', '', 'newline','pc'); 
            dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.fmri_spec.sess(', num2str(i_sess) ,').cond(', num2str(i_con) ,').tmod = 0;'), '-append', 'delimiter', '', 'newline','pc'); 

            if PoD_idx(i_con)==0
                dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.fmri_spec.sess(', num2str(i_sess) ,').cond(', num2str(i_con) ,').pmod = struct(''name'', {}, ''param'', {}, ''poly'', {});'), '-append', 'delimiter', '', 'newline','pc'); 
            elseif PoD_idx(i_con)==1            
                dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.fmri_spec.sess(', num2str(i_sess) ,').cond(', num2str(i_con) ,').pmod.name = ''',deblank(PoD_names{i_sess}(i_con)),''';'),'-append', 'delimiter', '', 'newline','pc'); 
                
                tem_PoD_onset=eval(['onsets{' num2str(i_sess) '}.'  PoD_var_names{i_sess}{i_con} ]); % pre-read the onset variable
                if size(tem_onset,1)>size(tem_onset,2) && size(tem_onset,2)==1 % judge whether it is a column vector
                    tem_PoD_onset=tem_PoD_onset'; % CHANGE it into row vector
                end  
            
                dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.fmri_spec.sess(', num2str(i_sess) ,').cond(', num2str(i_con) ,').pmod.param = [',num2str(tem_PoD_onset) ,'];'), '-append', 'delimiter', '', 'newline','pc'); 
                dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.fmri_spec.sess(', num2str(i_sess) ,').cond(', num2str(i_con) ,').pmod.poly = 1;'), '-append', 'delimiter', '', 'newline','pc'); 
            end
            
            dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.fmri_spec.sess(', num2str(i_sess) ,').multi = {''''};'), '-append', 'delimiter', '', 'newline','pc'); 
            dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.fmri_spec.sess(', num2str(i_sess) ,').regress = struct(''name'', {}, ''val'', {});'), '-append', 'delimiter', '', 'newline','pc'); 
            if strcmp(h_rp,'No')
                dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.fmri_spec.sess(', num2str(i_sess) ,').multi_reg = {''''};'), '-append', 'delimiter', '', 'newline','pc'); 
            elseif strcmp(h_rp,'Yes')
                rp_txt= spm_select('FPList',deblank(full_dirs{i_sess}{i_subj}),'^rp_*.*txt');
                dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.fmri_spec.sess(', num2str(i_sess) ,').multi_reg = {''', rp_txt,'''};'), '-append', 'delimiter', '', 'newline','pc'); 
            end
            dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.fmri_spec.sess(', num2str(i_sess) ,').hpf = 128;'), '-append', 'delimiter', '', 'newline','pc'); 
        end
    end

        dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.fmri_spec.fact = struct(''name'', {}, ''levels'', {});'), '-append', 'delimiter', '', 'newline','pc'); 
        dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];'), '-append', 'delimiter', '', 'newline','pc'); % No derivatives
        dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.fmri_spec.volt = 1;'), '-append', 'delimiter', '', 'newline','pc'); 
        dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.fmri_spec.global = ''None'';'), '-append', 'delimiter', '', 'newline','pc'); 
        dlmwrite(write_name,strcat(['matlabbatch{1}.spm.stats.fmri_spec.mask = {''', deblank(em), '''};']), '-append', 'delimiter', '', 'newline','pc'); 
        dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.fmri_spec.cvi = ''AR(1)'';'), '-append', 'delimiter', '', 'newline','pc'); 
end

fprintf('\n-----Check the created job file(.m) under : %s \n-----Then run these job files in either SPM8 or Grocer!\n',root_dir )


