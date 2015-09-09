function [ROI_TCs,ROI_corr,FCmaps]=FG_fc_1subj(fc_type,imgs,rois,brainmask,h_detrend,h_bandpass,h_headmotion,h_globalmean,h_White_CSF,h_cov, ...
                               ASamplePeriod, ALowPass_HighCutoff, AHighPass_LowCutoff, AAddMeanBack, ...
                               White,CSF,cov_files)
%% Same as in REST, use "partial correlation" to calcualte FC while there are covariates

if nargin==0       
%    fc_type=questdlg('What kind of functional connectivity do you want to perform?', ...
%                     'FC type...','ROI-AllVoxels','Voxel-AllVoxels','ROIs-ROIs','ROI-AllVoxels') ;                
     fc_type={'ROI-AllVoxels','ROIs-ROIs','Voxel-AllVoxels', 'The first Two'}; 
     defSelection=fc_type{4};
     iSel=FG_questdlg(fc_type, 'FC type..', defSelection, 'What kind of functional connectivity do you want to perform?',[2;2]); 
     fc_type=fc_type{iSel}; 
     if isempty(fc_type), return, end  
   
  
   imgs = spm_select(inf,'any','Select the images under a subject folder...', [],pwd,'.*img$|.*nii$');
   if isempty(imgs), return, end
 
  
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


%%%%%%%%%%%%%%%%%%%%%%%  main process   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%
subj_dir=FG_separate_files_into_name_and_path(imgs(1,:)); % get the root folder of this subj
if isempty(brainmask)
    fprintf('\n---You must specify a whole brain mask for this job...')
    return
end

[root_dir,subj_name]=FG_sep_group_and_path(subj_dir);
write_dir=fullfile(root_dir,'FC_ROI_Names_TCs_Individual');
% output dir
if ~(exist(write_dir,'dir')==7) % cliff
   mkdir(write_dir);
end

%% --- Start : prepare for the covs --- %%
        if strcmp(h_headmotion,'Yes')
           rp_txt= spm_select('FPList',deblank(subj_dir),'^rp_*.*txt');
           fprintf('\n--No rp*.txt detected, the 6 head-motion parameters will not be removed from the imgs of this subj...')
        end   

        if ~isempty(rp_txt)
            rp=load(rp_txt);
        else
            rp=[]; 
        end   

        if strcmp(h_globalmean,'Yes')
            img_vols=FG_read_vols(imgs);
            for i=1:size(img_vols,4)
                globalmean(i,1)=spm_global(img_vols(:,:,:,i));
            end
            clear img_vols;
        else
            globalmean=[];
        end
        

        if strcmp(h_White_CSF,'Yes')
           White_CSF=FG_get_meanCBF_TC_in_ROIs_singlesubDir_CMD(imgs,brainmask,strvcat(White,CSF),'-inf','inf');
        else
           White_CSF=[];
        end  

        if strcmp(h_cov,'Yes')
           if isempty(cov_files)
               covs=[];
               fprintf('\n--No additional covariate files selected, No additional covariates will not be removed from the imgs of this subj...')
           else
               covs=[];
               for j=1:size(cov_file,1)
                  covs=[covs load(cov_files(j,:))];
                  % cov=FG_read_txt_row_by_row(cov_files);
               end
           end  
        else
            covs=[];
        end
        
        Covariates=[rp globalmean White_CSF covs]; 
%% --- End : prepare for the covs --- %%

    
if strcmp(h_detrend,'Yes')
    imgs=FG_linear_detrend_selected_imgs(imgs); % img: will be rewritten as detrended_imgs
    detrended_dir=FG_separate_files_into_name_and_path(imgs(1,:));
end

if strcmp(h_bandpass,'Yes')
    imgs=FG_bandpass_filter(detrended_dir,imgs, ...
                                    ASamplePeriod, ... 
                                    ALowPass_HighCutoff, ... 
                                    AHighPass_LowCutoff, ...
                                    AAddMeanBack, ...
                                    brainmask);  % img: will be rewritten as bandfiltered_imgs
end


% regress out all covariates
if ~isempty(Covariates)
    brainmask_vol=FG_read_vols(brainmask);
    imgs=FG_RegressOutCovariables(imgs,brainmask_vol,Covariates,0); % img: will be rewritten as Covs_removed_imgs
    % clear brainmask_vol
end


% get the ROI time-courses
ROI_TCs=FG_get_meanCBF_TC_in_ROIs_singlesubDir_CMD(imgs,brainmask,rois,'-inf','inf');
save_ROI_name_and_TC(write_dir,subj_name,rois,ROI_TCs);

% do FCs
% img_vols=FG_read_vols(imgs);
FCmaps=[];ROI_corr=[];
switch fc_type
    case 'ROI-AllVoxels'
        FCmaps=FG_correlation_ROIs_AllVoxels_fast(ROI_TCs,imgs,brainmask_vol);
    case 'ROIs-ROIs'
        ROI_corr=FG_correlation_ROIs_ROIs(ROI_TCs,0);
    case 'Voxel-AllVoxels'
        FCmaps=FG_correlation_voxel_AllVoxels_fast(imgs,brainmask_vol);
    case 'The first Two'
        ROI_corr=FG_correlation_ROIs_ROIs(ROI_TCs,0);  
        FCmaps=FG_correlation_ROIs_AllVoxels_fast(ROI_TCs,imgs,brainmask_vol);              
end

if ~isempty(ROI_corr)
    write_dir1=fullfile(root_dir,'FC_Corr_of_EachPair_of_ROI');
    % output dir
    if ~(exist(write_dir1,'dir')==7) % cliff
       mkdir(write_dir1);
    end
    save_ROI_corr(write_dir1,subj_name,ROI_corr)   ;
end

fprintf('\n---done...')


%%% subfunction %%%
function save_ROI_name_and_TC(write_dir,subj_name,rois,ROI_TCs)
    write_name=FG_check_and_rename_existed_file(fullfile(write_dir,'ROI_Names.txt'));
    dlmwrite(write_name, rois ,'-append', 'delimiter', '', 'newline','pc');
    
    write_name1=FG_check_and_rename_existed_file(fullfile(write_dir,[subj_name '_ROI_TCs.txt']));    
    save(write_name1, 'ROI_TCs', '-ASCII', '-DOUBLE','-TABS')

function save_ROI_corr(write_dir,subj_name,ROI_corr)   
    write_name1=FG_check_and_rename_existed_file(fullfile(write_dir,[subj_name 'Corr_of_EachPair_of_ROI.txt']));    
    save(write_name1, 'ROI_corr', '-ASCII', '-DOUBLE','-TABS')
