function FG_voxbo_vb2img_matlab
clc

%%%% vbimg

h=questdlg('**. It is going to continue to do vb2img, are you sure to continue?','Step2 VB2img....','Yes','Skip','Skip') ;

switch h
    case 'Yes'   
          t1_out=inputdlg('Please enter the output-name of T1 for all subjects...','T1 name...',1,{'t1'});
          h=questdlg('Are all names of T1-folder under each subject same ? If <Yes>, you can select one for all; Otherwise, you can use a folder filter or selcet T1-folder subj-by-subj! ','T1-folder names...','Yes','Use-folder_filter','Select-1_by_1','Yes') ;
          switch h
              
                case 'Yes'    
                    root_dir = FG_module_select_root('Select the root folder containing all subject folders');
                    if any(strcmpi('return',{root_dir})), return; end

                    [dirs_g,all_subs_dir]=FG_module_select_groups('Select all subject folders under the root folder');
                    if any(strcmpi('return',{dirs_g,all_subs_dir})), return; end


                    [dirs]=FG_module_select_groups('Select a T1 folders under a subjects [Make sure all other subject''s T1 folders have same name]');
                    if any(strcmpi('return',{dirs})), return; end


                   for i=1:size(all_subs_dir,1) 
                       try
                           eval(['!vb2img ''' fullfile(deblank(all_subs_dir(i,:)), dirs(1,:)) ''' ''' fullfile(deblank(all_subs_dir(i,:)),t1_out{1}) '''']) 
                           % eval(['system(''vb2img ' deblank(all_subs_dir(i,:)) dirs(1,:) ' ' deblank(all_subs_dir(i,:)) t1_out{1} ')']) 
                       catch me
                           me.message
                           continue
                       end
                   end
                case 'Use-folder_filter'
                    root_dir = FG_module_select_root('Select the root folder containing all the subject folders');
                    if any(strcmpi('return',{root_dir})), return; end

                    [dirs_g,all_subs_dir]=FG_module_select_groups('Select all subject folders under the root folder');
                    if any(strcmpi('return',{dirs_g,all_subs_dir})), return; end


                    dlg_prompt={'Specify a folder filter to get a second chance to do vb2img automatically'};
                    dlg_name='Folder filter...';
                    dlg_def={'*MPRAGE*'};
                    Ans=inputdlg(dlg_prompt,dlg_name,1,dlg_def,'on'); 

                     for i=1:size(all_subs_dir,1) 
                         try 
                             tem=dir(fullfile(deblank(all_subs_dir(i,:)),Ans{1}));    
                             eval(['!vb2img ''' fullfile(deblank(all_subs_dir(i,:)), tem.name) ''' ''' fullfile(deblank(all_subs_dir(i,:)),t1_out{1}) '''']) 
                             % eval(['system(''vb2img '  deblank(all_subs_dir(i,:)) tem.name  ' ' deblank(all_subs_dir(i,:)) t1_out{1} ')'])
                         catch me
                             me.message
                             continue
                         end
                     end
                    
              case 'Select-1_by_1'
                    root_dir = FG_module_select_root('Select the root folder containing all the subject folders');
                    if any(strcmpi('return',{root_dir})), return; end

                    [dirs_g,all_subs_dir]=FG_module_select_groups('Select all subject folders under the root folder');
                    if any(strcmpi('return',{dirs_g,all_subs_dir})), return; end
                    
                    for i=1:size(all_subs_dir,1) 
                        tem_dirs{i}=spm_select(1,'dir',['Please select the T1 folder for ' deblank(dirs_g(i,:))],[],deblank(all_subs_dir(i,:)));
                    end
                    pause(0.5)
                    for i=1:size(all_subs_dir,1) 
                         try         
                             eval(['!vb2img ''' deblank(tem_dirs{i}) ''' ''' fullfile(deblank(all_subs_dir(i,:)),t1_out{1}) ''''])                             
                         catch me
                             me.message
                             continue
                         end
                    end
                    
          end
          
    case 'Skip'
        
        fprintf('Skip the second step: vb2img............\n\n')
end

fprintf('Vb2img for your selection is done..........\n\n')
