function FG_reorganize_timepoints_as_subjects_Trash
%   this function restructure your study file into what Grocer need
% If your original folder sturcture are like below:

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
%
%  then this script will reorganize folders as below
%   - timepoints_as_subjs
%      - subj_timepoint01
%        - vol_001_subj_1.nii
%        - vol_001_subj_2.nii
%        - ...
%      - subj_timepoint02
%        - vol_002_subj_1.nii
%        - vol_002_subj_2.nii
%        - ...
%
% go to the working dir that is used to store the spm_job batch codes
clc
root_dir = spm_select(1,'dir','Select the root folder of a group of subjects', [],pwd);
     if isempty(root_dir)
        return
     end
cd (root_dir)


all_subs_dir = spm_select(inf,'dir','Select all subjects'' folders under this group', [],pwd);
    if isempty(all_subs_dir)
        return
    end
dirs=spm_str_manip(spm_str_manip(all_subs_dir,'dh'),'dc');  % take use of the "spm_str_manip" function
 
    if size(dirs,1)==1   % in this condition, [spm_str_manip(spm_str_manip(dirs,'dh'),'dc')] can't get the subject dirctories
       i=size(dirs,2); 
       success=0;
       for j=i:-1:1
           if dirs(j)==filesep
               success=1;
               break
           end
       end
       if success==1
           dirs=dirs(j+1:end);
       end
    end
    
    
imgs = spm_select(inf,'any','Select all the functional imgs(hdr/img) under a subject', [],pwd,'^w.*img$|^w.*nii$');
    if isempty(imgs)
        return
    end  
%[a,b,c,d]=fileparts(imgs)    
imgs=spm_str_manip(imgs,'dc');  % take use of the "spm_str_manip" function
  if size(imgs,1)==1
      [a,b,c,d]=fileparts(imgs);
      imgs=[b c];
  end
    
% create all the timepoint folders
mkdir timepoints_as_subjs    
for i=1:size(imgs,1)
    if i<10
        mkdir(['timepoints_as_subjs' filesep 'subjs_timepoint00' num2str(i)]) ;
    elseif i>9 & i<100
        mkdir(['timepoints_as_subjs' filesep 'subjs_timepoint0' num2str(i)]) ;
    else
        mkdir(['timepoints_as_subjs' filesep 'subjs_timepoint' num2str(i)]) ;
    end
end

fprintf('\n---- Reorganizing files....')
for j=1:size(imgs,1)
        [a,b,c,d]=fileparts(deblank(imgs(j,:)));
    for i=1:size(all_subs_dir,1)
        if j<10
            copyfile([deblank(all_subs_dir(i,:)) b c],['timepoints_as_subjs' filesep 'subjs_timepoint00' num2str(j) filesep b '_' deblank(dirs(i,:)) c]) ;
            copyfile([deblank(all_subs_dir(i,:)) b '.hdr'],['timepoints_as_subjs' filesep 'subjs_timepoint00' num2str(j) filesep b '_' deblank(dirs(i,:)) '.hdr']) ;
        elseif j>9 & j<100
            copyfile([deblank(all_subs_dir(i,:)) b c],['timepoints_as_subjs' filesep 'subjs_timepoint0' num2str(j) filesep b '_' deblank(dirs(i,:)) c]) ; 
            copyfile([deblank(all_subs_dir(i,:)) b '.hdr'],['timepoints_as_subjs' filesep 'subjs_timepoint0' num2str(j) filesep b '_' deblank(dirs(i,:)) '.hdr']) ;

        else
            copyfile([deblank(all_subs_dir(i,:)) b c],['timepoints_as_subjs' filesep 'subjs_timepoint' num2str(j) filesep b '_' deblank(dirs(i,:)) c]) ; 
            copyfile([deblank(all_subs_dir(i,:)) b '.hdr'],['timepoints_as_subjs' filesep 'subjs_timepoint' num2str(j) filesep b '_' deblank(dirs(i,:)) '.hdr']) ;
        end
    end
end

fprintf('\n---- Timepoints have been reorganized as subjects!\n\n')
fprintf('\n---- Output: %s%s    \n\n',root_dir,'timepoints_as_subjs')