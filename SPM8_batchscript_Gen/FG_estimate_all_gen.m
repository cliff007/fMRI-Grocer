function FG_estimate_all_gen

dirs = spm_select(inf,'dir','Select all output folders containing SPM.mat files', [],pwd,'.*'); 

write_name=['estimate_all_'  num2str(size(dirs,1)) 'job.m'];  
% build the batch header
dlmwrite(write_name,'%-----------------------------------------------------------------------', 'delimiter', '', 'newline','pc'); 
dlmwrite(write_name, '% Job configuration created by cfg_util (rev $Rev: 3944 $)', '-append', 'delimiter', '', 'newline','pc');
dlmwrite(write_name,'%-----------------------------------------------------------------------', '-append', 'delimiter', '', 'newline','pc'); 
    
for j=1:size(dirs,1)
    tem=deblank(dirs(j,:));
    tem=tem(1:end-1);
    P = spm_select('FPList',tem ,'SPM.mat$');
    
    dlmwrite(write_name,strcat('matlabbatch{', num2str(j), '}.spm.stats.fmri_est.spmmat = {'), '-append', 'delimiter', '', 'newline','pc');     
    dlmwrite(write_name,['''' P ''''], '-append', 'delimiter', '', 'newline','pc');
    dlmwrite(write_name,'};', '-append', 'delimiter', '', 'newline','pc');
    
    dlmwrite(write_name,strcat('matlabbatch{', num2str(j), '}.spm.stats.fmri_est.method.Classical = 1;'), '-append', 'delimiter', '', 'newline','pc'); 
    
end

fprintf('\n-----Check the created job file(.m): %s \n-----Then run the job file in either SPM8 or Grocer!\n',write_name)