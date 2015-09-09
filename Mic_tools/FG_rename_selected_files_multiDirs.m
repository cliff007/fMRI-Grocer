function FG_rename_selected_files_multiDirs

all_subs_dir = spm_select(inf,'dir','Select all subjects'' folders under a group', [],pwd);
if FG_check_ifempty_return(all_subs_dir), return;  end 

    prompt = {'Specify the file filters(e.g. "*.m", "CBF*")'};
    num_lines = 1;
    def = {'*.*'};
    dlg_title='filters...';
    aa = inputdlg(prompt,dlg_title,num_lines,def);
    filter1 =aa{1};

for i_D=1:size(all_subs_dir,1)  
    % first folder
    if i_D==1
        [all_files,all_cell_files]=FG_list_one_level_files(deblank(all_subs_dir(i_D,:)),filter1);
        fprintf('\n------%s ',deblank(all_subs_dir(i_D,:)));
        [h,h1,Ans]=FG_file_rename_options(all_files);
    else
         [all_files,all_cell_files]=FG_list_one_level_files(deblank(all_subs_dir(i_D,:)),filter1);
         fprintf('\n------%s ',deblank(all_subs_dir(i_D,:)));
         FG_file_rename_options(all_files,h,h1,Ans);    
    end
end


 fprintf('\n------All are done!\n');