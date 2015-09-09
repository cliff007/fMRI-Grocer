function FG_voxbo_vb2imgs_matlab
clc
 
%%%% vbimgs 

h=questdlg('**. It is going to do vb2imgs, are you sure to continue?','Step3: VB2imgs....','Yes','Skip','Skip') ;
 switch h
    case 'Yes'
 
        % uiwait(msgbox('In case of different folder names of different subjects, you can only do this vb2imgs step subj by subj!','Be patient...','warn','modal'))
        h=questdlg(['Are all names of the functional groups of each subject same ? If <Yes>, you can select one for all; Otherwise, you can use a folder filter or selcet T1-folder subj-by-subj!'], 'Functional group names...','Yes','Use-folder_filter', 'Select-1_by_1','Yes');
        switch h
            case 'Yes'


                root_dir = FG_module_select_root('Select root folder containing all the subject folders');
                if any(strcmpi('return',{root_dir})), return; end

                [dirs_g,all_subs_dir]=FG_module_select_groups('Select all subject folders under the root folder');
                if any(strcmpi('return',{dirs_g,all_subs_dir})), return; end

                groups=FG_module_select_groups('Select all the functional groups under the subject');
                if any(strcmpi('return',{groups})), return; end   


                a=which('FG_Output_folder_names')   ;
                [b,c,d,e]=fileparts(a);
                Outdir = spm_select(1,'.m','Select the file of Output-group-names (FG_Output*.m) for your selected functional groups(Edit it before you select)', [],b,'FG_Output*.*m');
                addpath(FG_sep_group_and_path(Outdir));
                if ~isempty(Outdir)
                    [b,c,d,e]=fileparts(Outdir);
                else
                    return;
                end
                eval(['[Out_group_name,Out_subj_name]=' c ';'])    ;

                if size(Out_group_name,1)~=size(groups,1)
                    msgbox('the num of out_names is different from your selected functional groups of this sbuject','Error...','warn')
                    return
                end

                for j=1:size(all_subs_dir,1)        
                    for  i=1:size(groups,1)
                        try 
                            % eval(['system(''vb2imgs ' deblank(all_subs_dir(j,:)) deblank(groups(i,:)) ' ' deblank(all_subs_dir(j,:)) deblank(Out_group_name{i}) ''')'])  
                            eval(['!vb2imgs ''' fullfile(deblank(all_subs_dir(j,:)),deblank(groups(i,:))) ''' ''' fullfile(deblank(all_subs_dir(j,:)),deblank(Out_group_name{i})) ''''])  
                        catch me
                            me.message
                            continue
                        end
                    end
                end

            case 'Use-folder_filter'

                root_dir = FG_module_select_root('Select root folder containing all the subject folders');
                if any(strcmpi('return',{root_dir})), return; end

                [dirs_g,all_subs_dir]=FG_module_select_groups('Select all subject folders under the root folder');
                if any(strcmpi('return',{dirs_g,all_subs_dir})), return; end
                
                dlg_prompt={'Specify a folder filter to get a second chance to do vb2imgs automatically'};
                dlg_name='Folder filter...';
                dlg_def={'*pcasl*'};
                Ans=inputdlg(dlg_prompt,dlg_name,1,dlg_def,'on'); 

                a=which('FG_Output_folder_names')   ;
                [b,c,d,e]=fileparts(a);
                Out_name = spm_select(1,'.m','Select the Output-names file of your selected functional groups of a subject(Edit it before you select)', [],b,'FG_Output*.*m');
                addpath(FG_sep_group_and_path(Out_name));
                if ~isempty(Out_name)
                    [b,c,d,e]=fileparts(Out_name);
                else
                    return;
                end
                eval(['Out_name=' c ';'])    ;

                 for num_subj=1:size(dirs_g,1)  
                    tem=dir(fullfile(deblank(all_subs_dir(num_subj,:)),Ans{1}));
                    if size(Out_name,1)~=size(tem,1)
                        msgbox(['the num of out_names is different from functional groups found in ' deblank(dirs_g(num_subj,:))],'Error...','warn')
                        return
                    end 
                    
                    for  i=1:size(tem,1)      
                        try
                            full_tem=fullfile(deblank(all_subs_dir(num_subj,:)),deblank(tem(i).name));
                            eval(['!vb2imgs ''' deblank(full_tem) ''' ''' fullfile(deblank(all_subs_dir(num_subj,:)),deblank(Out_name{i})) ''''])  
                            % eval(['system(''vb2imgs ' deblank(full_tem(i,:)) ' ' deblank(all_subs_dir(num_subj,:)) deblank(Out_name{i}) ''')'])  
                        catch me
                            me.message
                            continue
                        end
                    end
                    fprintf('\n==Vb2imgs for %s is done............\n\n', deblank(dirs_g(num_subj,:)))
                 end
             
            case 'Select-1_by_1'

                root_dir = FG_module_select_root('Select root folder contain all the subject folders');
                if any(strcmpi('return',{root_dir})), return; end

                [dirs_g,all_subs_dir]=FG_module_select_groups('Select all subject folders under the root folder');
                if any(strcmpi('return',{dirs_g,all_subs_dir})), return; end
                
                a=which('FG_Output_folder_names')   ;
                [b,c,d,e]=fileparts(a);
                Out_name = spm_select(1,'.m','Select the Output-names file of your selected functional groups of a subject(Edit it before you select)', [],b,'FG_Output*.*m');
                addpath(FG_sep_group_and_path(Out_name));
                if ~isempty(Out_name)
                    [b,c,d,e]=fileparts(Out_name);
                else
                    return;
                end
                eval(['Out_name=' c ';'])    ;
                

                 for i=1:size(dirs_g,1)                      
                     tem_dirs{i}=spm_select(size(Out_name,1),'dir',['Please select ' num2str(size(Out_name,1)) ' functional groups for ' deblank(dirs_g(i,:))],[],deblank(all_subs_dir(i,:)));
                 end
                 
                 for num_subj=1:size(dirs_g,1)  
                    for  i=1:size(tem_dirs{num_subj},1)      
                        try
                            eval(['!vb2imgs ''' deblank(tem_dirs{num_subj}(i,:)) ''' ''' fullfile(deblank(all_subs_dir(num_subj,:)), deblank(Out_name{i})) '''']) 
                            % eval(['system(''vb2imgs ' deblank(full_tem(i,:)) ' ' deblank(all_subs_dir(num_subj,:)) deblank(Out_name{i}) ''')'])  
                        catch me
                            me.message
                            continue
                        end
                    end
                    fprintf('\n==Vb2imgs for %s is done............\n\n', deblank(dirs_g(num_subj,:)))
                 end
                
                
        end
     
     case 'Skip'
        fprintf('Skip the third step: vb2imgs..............\n\n')
 end


 fprintf('---------- vb2imgs for your selection is done~~\n\n')
