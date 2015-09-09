function [h_mean,mean_fun_imgs_tem,mean_file_filter]=FG_module_select_mean_Img(groups,opts,file_filter_for_auto)
% select n-subject folders
if nargin==0
  opts=FG_module_settings_of_questdlg;
  groups = FG_module_select_groups;  
   file_filter_for_auto='^mean.*img$|^mean.*nii$';    
elseif nargin==1
   opts=FG_module_settings_of_questdlg;
   file_filter_for_auto='^mean.*img$|^mean.*nii$';    
elseif nargin==2
   file_filter_for_auto='^mean.*img$|^mean.*nii$'; 
end

mean_fun_imgs_tem=[];
h_mean=questdlg(opts.mean.prom,opts.mean.title,opts.mean.oper{1},opts.mean.oper{2},opts.mean.oper{3},opts.mean.oper{1}) ; 
    if strcmp(h_mean,opts.mean.oper{1})
       mean_fun_imgs_tem =  spm_select(inf,'any','Select a mean* imgs ', [],pwd,file_filter_for_auto);  
       if FG_check_ifempty_return(mean_fun_imgs_tem), mean_fun_imgs_tem='return'; return; end
       mean_fun_imgs_tem=spm_str_manip(mean_fun_imgs_tem,'dt');
       mean_file_filter =file_filter_for_auto;
    elseif strcmp(h_mean,opts.mean.oper{2})
        for g=1:size(groups,1)
            mean_fun_imgs_tem{g} = spm_select(inf,'any',['Select all a mean* imgs of group:' groups(g,:)], [],pwd,file_filter_for_auto);
            if FG_check_ifempty_return(mean_fun_imgs_tem{g}) , mean_file_filter='return'; return; end
            mean_fun_imgs_tem{g}=spm_str_manip(mean_fun_imgs_tem{g},'dt');
        end
        mean_file_filter =file_filter_for_auto;
    elseif strcmp(h_mean,opts.mean.oper{3})
        prompt = {'Specify a file filter (You should use Matlab asterrisk wildcard [ ^ $ * etc. ]):'};
        num_lines = 1;
        def = {file_filter_for_auto};
        dlg_title='filter...';
        mean_file_filter = inputdlg(prompt,dlg_title,num_lines,def);
        mean_file_filter =mean_file_filter{1};
    end

