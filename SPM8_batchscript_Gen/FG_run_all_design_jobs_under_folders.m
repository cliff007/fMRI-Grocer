function FG_run_all_design_jobs_under_folders

dirs = spm_select(inf,'dir','Select all output folders containing SPM.mat files', [],pwd,'.*'); 

% write_name=['estimate_all_'  num2str(size(dirs,1)) 'job.m'];  
all_job_file=[];
for j=1:size(dirs,1)
    tem=deblank(dirs(j,:));
    tem=tem(1:end-1);
    P = spm_select('FPList',tem ,'\job.m$');  
    all_job_file=strvcat(all_job_file,P);   
end

if size(dirs ,1)~=size(all_job_file,1)
   display(all_job_file)
   choice= questdlg(['You select ' num2str(size(dirs ,1)) ' folders, but '  num2str(size(all_job_file,1)) ' job files were detected! Please check the the file list in the command window and then decide whether to continue!'],'Continue or not...','Yes','No','No') ;
   if strcmp(choice,'Yes')
       FG_run_all_jobs (all_job_file);
   else
       return
   end
end

FG_run_all_jobs (all_job_file)
