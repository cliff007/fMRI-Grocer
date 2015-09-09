function FG_backconstruct_folder_structure_from_GROCER
%   this function restructure your study file into what Grocer need
% If your original folder sturcture are like below:
%
%   - fMRI study root path
%     - functional_group1_Data
%       - subj_1
%         - vol_001.nii    
%         - vol_002.nii
%         - ...
%       - subj_2
%         - vol_001.nii
%         - vol_002.nii
%         - ...
%       - subj_n
%         - ...
%     - functional_group2_Data
%       - subj_1
%         - vol_001.nii    
%         - vol_002.nii
%         - ...
%       - subj_2
%         - vol_001.nii
%         - vol_002.nii
%         - ...
%       - subj_n
%         - ...
%     - functional_group2_Data
%       - ... 
%     - anatomy_data
%       - t1_subj_001.nii      ------ t1 imgs' order must be the same as the subject folders'.
%       - t1_subj_002.nii
%       - ...
%
%  Then this function can copy all files into the structure as below:
%
%  - fMRI study root path
%    - subj_1
%      - functional_group1_Data
%        - vol_001.nii    
%        - vol_002.nii
%      - functional_group2_Data
%        - vol_001.nii    
%        - vol_002.nii
%      - T1.nii
%    - subj_2
%      - functional_group1_Data
%        - vol_001.nii    
%        - vol_002.nii
%      - functional_group2_Data
%        - vol_001.nii    
%        - vol_002.nii
%      - T1.nii
%

%
% go to the working dir that is used to store the spm_job batch codes

%     anyreturn=FG_modules_selection('','','','.*img$|.*nii$','r','g','fo','fi');
anyreturn=FG_modules_selection('','','','.*img$|.*nii$','r','g','fo','t');
if anyreturn, return;end

    
h1=questdlg('Backconstruct T1s to the root of subject folder or to a separate folder under the subject folder?','T1 imgs....','RootFolder','SepFolder','RootFolder') ;



des_dir = spm_select(1,'dir','Select a folder to save the output files', [],pwd);
     if isempty(des_dir)
        return
     end

fprintf('\n------Folders backconstructing...\n\n')  

for g=1:size(groups,1)
    % assigning the subfolders of groups
    dirs=FG_module_assign_dirs(root_dir,dirs_tem,groups,g,folder_filter,h_folder,opts);
    % assigning the t1 of groups
    t1_imgs=FG_module_assign_t1(t1_imgs_tem,g,h_t1,opts);
    
    
    for j=1:size(dirs,1)       
        mkdir (fullfile(des_dir, deblank(dirs(j,:)), deblank(groups(g,:))))
        try
            copyfile (fullfile(root_dir,deblank(groups(g,:)),deblank(dirs(j,:))),fullfile(des_dir, deblank(dirs(j,:)), deblank(groups(g,:))));

            [a,b,c,d]=FG_fileparts(deblank(t1_imgs(j,:)));
            if strcmp(h1,'RootFolder')
               copyfile (fullfile(a,[b '.img']), fullfile(des_dir, deblank(dirs(j,:)))); 
               copyfile (fullfile(a,[b '.hdr']), fullfile(des_dir, deblank(dirs(j,:)))); 
            elseif strcmp(h1,'SepFolder')
                if exist(fullfile(des_dir, deblank(dirs(j,:)),'anat_T1'),'dir')==0
                    mkdir (fullfile(des_dir, deblank(dirs(j,:)),'anat_T1')) 
                end
                
                try
                   copyfile (fullfile(a,[b '.img']), fullfile(des_dir, deblank(dirs(j,:)),'anat_T1'));  
                   copyfile (fullfile(a,[b '.hdr']), fullfile(des_dir, deblank(dirs(j,:)),'anat_T1')); 
                catch me1
                    try
                        copyfile (fullfile(a,[b '.nii']), fullfile(des_dir, deblank(dirs(j,:)),'anat_T1')); 
                    catch me2
                    end
                end                   
            end

        catch me
            me.message
            continue
        end
    end
end




fprintf('\n------------Great!Folder has been backconstructured!\n\n')  
fprintf('\n------------Output:%s    \n\n',des_dir)

