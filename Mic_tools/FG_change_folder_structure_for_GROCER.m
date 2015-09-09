function FG_change_folder_structure_for_GROCER
%   this function restructure your study file into what Grocer need
% If your original folder sturcture are like below:
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
%  Then this function can copy all files into the structure as below:
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
% go to the working dir that is used to store the spm_job batch codes

root_dir = spm_select(1,'dir','Select the root folder of fMRI_stduy', [],pwd);
     if isempty(root_dir)
        return
     end
cd (root_dir)

     
all_subs_dir = spm_select(inf,'dir','Select all subjects'' folders', [],pwd);
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



groups = spm_select(inf,'dir','Select all the functional groups under a subject', [],pwd);
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
    
fprintf('\n------Folders reconstructing...\n\n')  

    
h=questdlg('Do you have a T1 img under each subject folder?','T1 imgs....','Yes','No','Yes') ;  
if strcmp(h,'Yes')
    h=questdlg('T1 is under each subject''s root folder or under a separate folder of subject''s root folder?','T1 imgs....','RootFolder','SepFolder','SepFolder') ;
end
if strcmp(h,'RootFolder')
    t1s = spm_select(1,'any','Select the T1 imgs of a subject', [],pwd,'.*img$|.*nii$');
     if isempty(t1s)
        return
     end  
    [a,b_t1,c,d]=fileparts(t1s);
elseif strcmp(h,'SepFolder')
    t1_dir = spm_select(1,'dir','Select the separate folder containing T1 img under root folder of a subject', [],pwd);  
    t1_tem=t1_dir ;
    % get the T1 folder name
       t1_dir = spm_str_manip(spm_str_manip(t1_dir,'dh'),'dc');
       i=size(t1_dir,2); 
       success=0;
       for j=i:-1:1
           if t1_dir(j)==filesep
               success=1;
               break
           end
       end
       if success==1
           t1_dir=t1_dir(j+1:end);
       end
       
    t1s = spm_select(1,'any','Select the T1 imgs of a subject', [],pwd,'.*img$|.*nii$');    

    [a,b_t1,c_t1,d]=fileparts(t1s);
    b_t1=[t1_dir filesep b_t1];  % make some adustment to make the following codes can work for both of these two conditions 
end


des_dir = spm_select(1,'dir','Select a folder to save the output files', [],pwd);
     if isempty(des_dir)
        return
     end

if exist('b_t1','var')
    mkdir ([des_dir 'ALL_T1s'])
end

for i=1:size(groups,1)
    mkdir ([des_dir deblank(groups(i,:))])
    for j=1:size(dirs,1)       
       mkdir ([des_dir deblank(groups(i,:)) filesep deblank(dirs(j,:))])
    end
end

h_confirm=questdlg('Do you need to further confirm the processes of functional and T1 img?','Confrim....','Yes','No','No') ;  
if strcmp(h_confirm,'No')
   h_fun='Yes'; 
   h_T1='Yes'; 
end

if ~strcmp(h_confirm,'No')
    h_fun=questdlg('Do you want to copy the functional groups into a new folder?','Fun imgs....','Yes','Skip','Skip') ;
end
pause(0.5)
if strcmp(h_fun,'Yes')
    for j=1:size(dirs,1)
        for i=1:size(groups,1)
            try
                copyfile([deblank(dirs(j,:)) filesep deblank(groups(i,:)) filesep '*'], ...
                    [des_dir deblank(groups(i,:)) filesep deblank(dirs(j,:))])
            catch ME  % in case of there are some missing conditions in some subjects
                continue
            end

        end
    end
end

if exist('t1s','var')
    if ~strcmp(h_confirm,'No')
        h_T1=questdlg('Do you want to copy the T1s into a new folder?','T1 imgs....','Yes','Skip','Skip') ;
    end
    pause(0.5)
    if strcmp(h_T1,'Yes')
        
        for j=1:size(dirs,1)
            
            try
                if strcmpi(c_t1,'.hdr') || strcmpi(c_t1,'.imgi')
                   copyfile([deblank(dirs(j,:)) filesep b_t1 '.hdr'], ...
                       [des_dir  'ALL_T1s' filesep deblank(dirs(j,:)) '_t1.hdr'])
                   copyfile([deblank(dirs(j,:)) filesep b_t1 '.img'], ...
                       [des_dir  'ALL_T1s' filesep deblank(dirs(j,:)) '_t1.img'])
                elseif strcmpi(c_t1,'.nii') 
                   copyfile([deblank(dirs(j,:)) filesep b_t1 '.nii'], ...
                       [des_dir  'ALL_T1s' filesep deblank(dirs(j,:)) '_t1.nii'])  
                end
            catch ME
                continue
            end
        end
    end
end

fprintf('\n------------Great!Folder structures has changed!\n\n')  
fprintf('\n------------Output:%s    \n\n',des_dir)

