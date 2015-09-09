function FG_delete_tempory_files_during_SPM_analysis(h_op,root_dir,file_filters,out_dir)
    if nargin==0
        h_op=questdlg('What do you want to do?','Hi....','Copy out...','Move out...', 'Delete in...','Copy out...') ;
        if isempty(h_op), return; end
        root_dir = FG_module_select_root('Select a root folder of the files/folders you want to deal with');

        prompt = {'How many file filters do you want to specify:'};
        num_lines = 1;
        def = {'1'};
        dlg_title='filter num....';
        file_filter_n = inputdlg(prompt,dlg_title,num_lines,def);
        file_filter_n =str2num(file_filter_n{1});
     % enter the file filters   
        dlg_prompt={};
        dlg_prompt1={};
        dlg_prompt2={};  
        dlg_title='filter...';
        for i=1:file_filter_n
            dlg_prompt1=[dlg_prompt1,['file filter',num2str(i),'----------------------------------']];
            dlg_prompt2=[dlg_prompt2,'CBF*.*'];
        end  
        file_filters =inputdlg(dlg_prompt1,dlg_title,num_lines,dlg_prompt2);
     
    end     
         
    display('----Listing folder structure...')        
    pause(0.5)
    all_dirs=FG_genpath(root_dir);  %   FG_genpath      
       
  

     %% for file delete in original folders  
     if strcmp(h_op,'Delete in...') 
        % delete the files under the root folders
        tem_root=deblank(all_dirs(i_dir,:)); 
        display(['----Dealing with ' tem_root])
        for i=1:size(file_filters,1)
            [a_all,all_files]=FG_list_all_files(tem_root,'*',file_filters{i});
            if isempty(a_all), continue,end
            try 
                delete([ '*.*']);
            catch me               
               
            end
        end
        fprintf('\n--------Deleting Folders is done !\n\n')
     end
 end