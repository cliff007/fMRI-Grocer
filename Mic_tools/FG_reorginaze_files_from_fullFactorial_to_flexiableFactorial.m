function FG_reorginaze_files_from_fullFactorial_to_flexiableFactorial
%   this function restructure your study file from the folder structure
%   that is suitable for factorial factorial degisn(not only) to the structure that
%   is suitable for flexiable factorial design(not only, e.g, ANOVA-withinsubject)
% If your original folder sturcture are like below:
%
%   - fMRI study root path
%     - condition1_Data
%         - sub1_vol_001.nii    
%         - sub2_vol_002.nii
%         - ...
%     - condition2_Data
%         - sub1_vol_001.nii    
%         - sub2_vol_002.nii
%         - ...
%     - condition3_Data
%         - sub1_vol_001.nii    
%         - sub2_vol_002.nii
%         - ...
%%
%  Then this function can copy all files into the structure as below:
%
%  - fMRI study root path
%    - subj_1
%        - condition1_vol_001.nii    
%        - condition2_vol_001.nii 
%        - ...
%    - subj_2
%        - condition1_vol_001.nii    
%        - condition2_vol_001.nii 
%        - ...
%    - subj_3
%        - condition1_vol_001.nii    
%        - condition2_vol_001.nii 
%        - ...
%

% go to the working dir that is used to store the spm_job batch codes
clc
root_dir = spm_select(1,'dir','Select the root folder of original folders for full-factorial design', [],pwd);
     if isempty(root_dir)
        return
     end
cd (root_dir)

groups = spm_select(inf,'dir','Select all the condition folders', [],pwd);
     if isempty(groups)
        return
     end   

groups=spm_str_manip(spm_str_manip(groups,'dh'),'dc');  % take use of the "spm_str_manip" function

    if size(groups,1)==1   % in this condition, [spm_str_manip(spm_str_manip(groups,'dh'),'dc')] can't get the group dirctories
       i=size(groups,2); 
       success=0;
       for j=i:-1:1
           if groups(j)==filesep
               success=1;
               break
           end
       end
       if success==1
           groups=groups(j+1:end);
       end
    end
    

for i=1:size(groups,1)
    files(i)={spm_select('FPList',deblank(groups(i,:)),'.*img$|.*hdr$')};
    
    if i>1
        if size(files{i},1)~=size(files{i-1},1)
            fprint('\nThe number of files under all groups is not the same. i.e, the subjects under each condition is not the same!Check it out please!\n')
            return
        end
    end    
end    

mkdir For_flexiable_factorial_design
for i=1:size(files{1},1)/2 % so this just can deal with img/hdr paired files
    if i<10
        mkdir (['For_flexiable_factorial_design' filesep 'Subj0' num2str(i)]);
    elseif i<100 & i>9
        mkdir (['For_flexiable_factorial_design' filesep 'Subj' num2str(i)]);
    end
end
    
    i_sub=1;
for i=1:2:size(files{1},1) % so this just can deal with img/hdr paired files
    for j=1:size(groups,1)
        if i_sub<10
            [a,b,c,d]=fileparts(deblank(files{j}(i,:)));
            copyfile ([deblank(files{j}(i,:))],['For_flexiable_factorial_design' filesep 'Subj0' num2str(i_sub) filesep deblank(groups(j,:)) '_' b c]);
            [a,b,c,d]=fileparts(deblank(files{j}(i+1,:)));
            copyfile ([deblank(files{j}(i+1,:))],['For_flexiable_factorial_design' filesep 'Subj0' num2str(i_sub) filesep deblank(groups(j,:)) '_' b c]);      
        elseif i_sub<100& i_sub>9
            [a,b,c,d]=fileparts(deblank(files{j}(i,:)));
            copyfile ([deblank(files{j}(i,:))],['For_flexiable_factorial_design' filesep 'Subj' num2str(i_sub) filesep deblank(groups(j,:)) '_' b c]);
            [a,b,c,d]=fileparts(deblank(files{j}(i+1,:)));
            copyfile ([filesep deblank(files{j}(i+1,:))],['For_flexiable_factorial_design' filesep 'Subj' num2str(i_sub) filesep deblank(groups(j,:)) '_' b c]);      
        end
    end
    i_sub=i_sub+1;
end


fprintf('\n---Great!Folder structures has been changed!\n\n')  
fprintf('\n---Output:%s%s    \n\n',root_dir,'For_flexiable_factorial_design')

