function FG_fc_ngroup_nSubjs
% select folders and specify file filter
anyreturn=FG_modules_enhanced_selection('','','','.*img$|.*nii$','r','g','fo','fi');
if anyreturn, return;end  

if nargin==0    
   
       ASamplePeriod=[]; ALowPass_HighCutoff=[]; AHighPass_LowCutoff=[]; AAddMeanBack=[];
       White=[];CSF=[];cov_files=[];
    
    
%    fc_type=questdlg('What kind of functional connectivity do you want to perform?', ...
%                     'FC type...','ROI-AllVoxels','Voxel-AllVoxels','ROIs-ROIs','ROI-AllVoxels') ;                
     fc_type={'ROI-AllVoxels','ROIs-ROIs','Voxel-AllVoxels', 'The first Two'}; 
     defSelection=fc_type{4};
     iSel=FG_questdlg(fc_type, 'FC type..', defSelection, 'What kind of functional connectivity do you want to perform?',[2;2]); 
     fc_type=fc_type{iSel}; 
     if isempty(fc_type), return, end  
   
  
   if ~strcmp(fc_type,'Voxel-AllVoxels')
       rois = spm_select(inf,'any','Select ROIs that have the same resolution as functional imgs...', [],pwd,'.*img$|.*nii$');
       if isempty(rois), return, end   
   end   
   
     
    template_dir=fullfile(FG_rootDir('grocer'), 'Templates');
    brainmask = spm_select(1,'any','Must select a whole brain mask~', [],template_dir,'.*img$|.*nii$');


   h_detrend=questdlg('Do you want to linearly detrend the imgs?','Detrend...','Yes','No','Yes') ; 
   h_bandpass=questdlg('Do you want to do bandpass of the imgs?','Band pass...','Yes','No','Yes') ; 
   if strcmp(h_bandpass,'Yes')
       % define the bandpass parameters
        prompt = {'Enter your scan TR:','Enter the low pass high-cutoff:','Enter the high pass low-cutoff:', ...
                  'Add Mean back to the images after filtering(Yes or No):'};
        dlg_title = 'Filter the images...';
        num_lines = 1;
        def = {'2','0.08','0.01','Yes'};
        answer = inputdlg(prompt,dlg_title,num_lines,def);
        ASamplePeriod=str2num(answer{1});
        ALowPass_HighCutoff=str2num(answer{2});
        AHighPass_LowCutoff=str2num(answer{3});
        AAddMeanBack=answer{4};
   end
          
    h_headmotion=questdlg('Do you want to remove the 6 head-motion parameters?','Head motion...','Yes','No','Yes') ;     
    h_globalmean=questdlg('Do you want to remove the global mean of brain img?','Global mean...','Yes','No','Yes') ;  

    h_White_CSF=questdlg('Do you want to remove the white-matter and CSF signal of brain img?','Covariables...','Yes','No','Yes') ;
    if strcmp(h_White_CSF,'Yes')
       White= spm_select(1,'any','Select the white matter mask...', [], fullfile(FG_rootDir('grocer'),'Templates'),'^colin2_seg2_0.1_as_61*.*nii');
       CSF =  spm_select(1,'any','Select the csf mask...', [],fullfile(FG_rootDir('grocer'),'Templates'),'^colin2_seg3_0.1_as_61*.*nii');
    end  
    
    h_cov=questdlg('Do you want to have some other covariables to be removed?','Covariables...','Yes','No','No') ;
    if strcmp(h_cov,'Yes')
       cov_files = spm_select(inf,'any','Select all the covariable files...', [],pwd,'.*txt$');
    end  
    
end
pause(0.5); % for GUI redraw


for g=1:size(groups,1)   
    % assigning the subfolders of groups
    dirs=FG_module_assign_dirs(root_dir,dirs_tem,groups,g,folder_filter,h_folder,opts);           
  
   
    for i=1:size(dirs,1) 
        % assigning the fullname imgs of subjs
        imgs=FG_module_enhanced_read_funImgs(root_dir,groups,dirs,g,i,all_fun_imgs,file_filter,h_files,opts); 
        % do FC subj by subj
        [ROI_TCs,ROI_corr,FCmaps]=FG_fc_1subj(fc_type,imgs,rois,brainmask,h_detrend,h_bandpass,h_headmotion,h_globalmean,h_White_CSF,h_cov, ...
                                           ASamplePeriod, ALowPass_HighCutoff, AHighPass_LowCutoff, AAddMeanBack, ...
                                           White,CSF,cov_files);
                                       
    end
end

fprintf('\n---done....')

