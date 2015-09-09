function FG_run_all_jobs(varargin)

%%%% manually set the SPM modality as "fMRI"
    try
        Modality = spm_get_defaults('modality');
    catch me
        fprintf('\n==Manually set the SPM modality as "FMRI"\n')
        spm('defaults','FMRI');
    end

    
% the input variable should be a cell or char vector array
if nargin==0
    jobs=spm_select(inf,'any','Select all the vaild SPM job files(.mat or .m)', [],pwd,'.*mat$|.*m$');
    if isempty(jobs) , return; end
elseif nargin==1
    if iscell(varargin{1})
       jobs= char(varargin{1});
    else ischar(varargin{1})
        jobs= varargin{1};
    end
end



h=findobj('Tag','run_b');
init=get(h,'BackgroundColor');
set(h,'BackgroundColor','c')

spm_jobman('initcfg') % for the newest SPM8 before 2011/10/23
% spm('defaults','FMRI'); % for the newest SPM8 before 2011/10/23
[pth, name]=FG_separate_files_into_name_and_path(jobs);
clear pth
err=0;
err_info=[];
for i=1:size(jobs,1)
    try
        spm_jobman('run',deblank(jobs(i,:)))
        fprintf('\n~~~~~~~~~~~~~~~~~~~the No. %d/%d  job file you selceted has done~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n',i,size(jobs,1)) 
    catch me
        err=1;
        err_info=strvcat(err_info,['Job execution failed: ' deblank(name(i,:))]);
%         err_info=strvcat(err_info,['        ' me.message]);
        me.message
        fprintf('\n\n ====== No. %d/%d  job file: --- %s ---,  has something wrong, please check it out! ====== \n',i,size(jobs,1),deblank(name(i,:))) 
        continue
    end
    
end

set(h,'BackgroundColor',init);
fprintf('\n------- All jobs have been implemented!\n') 
if err
    write_name=['Job_failed_info_' FG_get_current_date_str '.txt'];
    dlmwrite(write_name,err_info, 'delimiter', '', 'newline','pc'); 
    uiwait(msgbox('Some jobs failed! Please check the error information in the command window!','Warning...','Warn','modal'))
    fprintf('\n ==== Please check the '' %s '' under the current directory ===\n\n',write_name) 
end



%%%%%%%%%%%%%
% manually set the SPM modality as "fMRI"
    try
        Modality = spm_get_defaults('modality');
    catch me
        spm('defaults','FMRI');
    end
