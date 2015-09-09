function newnames = spm_check_orientations_and_resliceToTarget(imgs,target)
newnames=[];
for i=1:size(imgs,1)
    all=strvcat(imgs(i,:),target);
    sts=spm_check_orientations(spm_vol(all));
    if sts==0
       new_name=FG_simpleresliceROI_to_target_space(imgs(i,:),target) ;
       newnames=strvcat(newnames,new_name);
    else
       newnames=strvcat(newnames,deblank(imgs(i,:))); 
    end
    
end