function [h_folder,dirs_tem,folder_filter]=FG_module_select_subjects_undergroups(groups,opts,folder_filter_for_auto)
% select n-subject folders
if nargin==0
  folder_filter_for_auto='*';   
  groups = FG_module_select_groups; 
  opts=FG_module_settings_of_questdlg;
elseif nargin==1
   folder_filter_for_auto='*'; 
   opts=FG_module_settings_of_questdlg;
elseif nargin==2
   folder_filter_for_auto='*'; 
end

dirs_tem=[];
folder_filter=[];

h_folder=questdlg(opts.folders.prom,opts.folders.title,opts.folders.oper{1},opts.folders.oper{2},opts.folders.oper{3},opts.folders.oper{1}) ;
    
    if strcmp(h_folder,opts.folders.oper{1})   
        % specify the num of imgs in each subject's dir
        all_subs_dir =  spm_select(inf,'dir','Select all subject folders of one group', [],pwd,folder_filter);
        if FG_check_ifempty_return(all_subs_dir) , dirs_tem='return'; return; end        
        dirs_tem=FG_get_groupfolder_names(all_subs_dir);  
        folder_filter=folder_filter_for_auto;
    elseif strcmp(h_folder,opts.folders.oper{2})
        for g=1:size(groups,1)
            all_subs_dir(g)={spm_select(inf,'dir',['Select all folders of one group:' groups(g,:)], [],pwd,folder_filter)};
            if FG_check_ifempty_return(all_subs_dir{g}) , dirs_tem='return'; return; end
            dirs_tem{g}=FG_get_groupfolder_names(all_subs_dir{g});             
        end
        folder_filter=folder_filter_for_auto;
    elseif strcmp(h_folder,opts.folders.oper{3})
        prompt = {'Specify a folder filter(Don''t miss the "*"):'};
        num_lines = 1;
        def = {folder_filter_for_auto};
        dlg_title='filter...';
        folder_filter = inputdlg(prompt,dlg_title,num_lines,def); 
        if FG_check_ifempty_return(folder_filter) , folder_filter='return'; return; end
        folder_filter=folder_filter{1};
    end
