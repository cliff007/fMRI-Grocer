function [h_t1,t1_imgs_tem]=FG_module_select_T1_Img(groups,opts)
% select n-subject folders
if nargin==0
  groups = FG_module_select_groups;  
  opts=FG_module_settings_of_questdlg;
end


    h_t1=questdlg(opts.t1.prom,opts.t1.title,opts.t1.oper{1},opts.t1.oper{2},opts.t1.oper{1}) ;
    if strcmp(h_t1,opts.t1.oper{1})
       t1_imgs_tem =  spm_select(inf,'any','Select all the T1 imgs ', [],pwd,'.*img$|.*nii$'); 
       if FG_check_ifempty_return(t1_imgs_tem), t1_imgs_tem='return'; return; end 
    elseif strcmp(h_t1,opts.t1.oper{2})
        for g=1:size(groups,1)
            t1_imgs_tem{g} =  spm_select(inf,'any',['Select all the T1 imgs for the group:' groups(g,:)], [],pwd,'.*img$|.*nii$');
            if FG_check_ifempty_return(t1_imgs_tem{g}) , t1_imgs_tem='return'; return; end             
        end
    end    

