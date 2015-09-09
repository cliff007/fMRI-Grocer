function [h_files,fun_imgs,all_fun_imgs,file_filter]=FG_module_enhanced_select_files_undersubjects(groups,opts,file_filter_for_auto)
% select n-subject files 
% add "all_fun_imgs" output
if nargin==0
  file_filter_for_auto='^sr.*img$|^sr.*nii$';  
  groups = FG_module_select_groups;  
  opts=FG_module_settings_of_questdlg;
elseif nargin==1
   file_filter_for_auto='^sr.*img$|^sr.*nii$'; 
   opts=FG_module_settings_of_questdlg;
elseif nargin==2
   file_filter_for_auto='^sr.*img$|^sr.*nii$';  
end

fun_imgs=[];
all_fun_imgs=[];
file_filter=[];

h_files=questdlg(opts.files.prom,opts.files.title,opts.files.oper{1},opts.files.oper{2},opts.files.oper{3},opts.files.oper{1}) ;

        if strcmp(h_files,opts.files.oper{1})   
            % specify the num of imgs in each subject's dir
            all_fun_imgs =  spm_select(inf,'any','Select all the fun_imgs of one subject', [],pwd,file_filter_for_auto);
            if FG_check_ifempty_return(all_fun_imgs) ,fun_imgs='return'; all_fun_imgs='return'; return; end
            fun_imgs=spm_str_manip(all_fun_imgs,'dt');
            file_filter=file_filter_for_auto;
        elseif strcmp(h_files,opts.files.oper{2})
            for g=1:size(groups,1)
                all_fun_imgs{g}=spm_str_manip(spm_select(inf,'any',['Select the fun_imgs of one subject:' groups(g,:)], [],pwd,file_filter_for_auto),'dt');
                if FG_check_ifempty_return(all_fun_imgs{g}), fun_imgs='return';all_fun_imgs='return'; return; end
            end
            file_filter=file_filter_for_auto;
        elseif strcmp(h_files,opts.files.oper{3})
            prompt = {'Specify a file filter(You should use asterrisk wildcard, e.g., ^,$,*,):'};
            num_lines = 1;
            def = {file_filter_for_auto};
            dlg_title='filter...';
            file_filter = inputdlg(prompt,dlg_title,num_lines,def);
            if FG_check_ifempty_return(file_filter),file_filter='return'; return; end
            file_filter =file_filter{1}; 
        end


