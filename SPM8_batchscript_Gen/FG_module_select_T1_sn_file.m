function [h_t1_sn,t1_imgs_sn_tem]=FG_module_select_T1_sn_file(groups,opts)
% select n-subject folders
if nargin==0
  groups = FG_module_select_groups; 
  opts=FG_module_settings_of_questdlg;
end

   % select T1_sn.mat imgs
    h_t1_sn=questdlg(opts.t1_sn.prom,opts.t1_sn.title,opts.t1_sn.oper{1},opts.t1_sn.oper{2},opts.t1_sn.oper{1}) ;
    if strcmp(h_t1_sn,opts.t1_sn.oper{1})
       t1_imgs_sn_tem =  spm_select(inf,'.mat','Select all the T1_sn.mat imgs ', [],pwd,'seg_sn.*mat'); 
       if FG_check_ifempty_return(t1_imgs_sn_tem) , t1_imgs_sn_tem='return'; return; end
    elseif strcmp(h_t1_sn,opts.t1_sn.oper{2})
        for g=1:size(groups,1)
            t1_imgs_sn_tem{g} =  spm_select(inf,'.mat',['Select all the T1_sn.mat imgs for the group:' groups(g,:)], [],pwd,'seg_sn.*mat');
            if FG_check_ifempty_return(t1_imgs_sn_tem{g}), t1_imgs_sn_tem='return';return; end              
        end 
    end   
    