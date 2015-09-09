function FG_image_quality_evaluation_ASL_v2(fun_imgs,write_name)
% turn the warning of matlab off, and close all the figures and progress bars        
    spm_figure('close',allchild(0));    
    
    if nargin==0
        warning off all % turn the warning of matlab off, 
        fun_imgs=spm_select(inf,'image','Select a group of images you want to evaluate...',[],pwd,'^p.*');         
    end
    
    fun_imgs=FG_remove_potential_dot1_of_image_names(fun_imgs); % remove the potential ",1"
    
    if isempty(fun_imgs)
        return
    elseif size(fun_imgs,1)<2
        fprintf('\n----Are you kidding? ------Not more than 2 images!\n\n')
        return
    end

% reset images' origin
     FG_reset_origin_selectedImgs(fun_imgs);
     
% read the first image info and set its path as the default output path
    imgmat=spm_vol(deblank(fun_imgs(1,:)));
    [root_dir,b,c,d]=fileparts(deblank(fun_imgs(1,:))); 
    [root_pth,root_sub]=FG_sep_group_and_path(deblank(root_dir));    
    root_first=[root_pth,root_sub '_corrected'];
    if ~exist(root_first,'dir')
        mkdir (root_first);
    end
    
    
    
    
    
    
    
    
%         %%%%%%%%%%%%%%%%%%%%%%%%    
%         %%% PCA method       
%         %     % Use PCA to explore the background images  
%         %% varargout=FG_pca_for_artifact(P, threshd) 
%           controls=fun_imgs(1:2:end,:);
%           varargout=FG_pca_for_artifact(controls, 0.9);
    
%%%%%%%%%%%%%%%%%%%%%%%%    
%%% permutation method    
%     % permutation 1000 times
        controls=fun_imgs(1:2:end,:);
        all_half_first=[];
        all_half_sec=[];
        fprintf('\n---- Doing permutation of controls...\n')
        for i=1:size(controls,1)
            permuated_order=randperm(size(controls,1));
            permuated_ctrls=controls(permuated_order,:);
            half_first=permuated_ctrls(1:ceil(0.5*size(controls,1)),:);
            half_sec=permuated_ctrls(ceil(0.5*size(controls,1))+1:end,:);
            all_half_first=strvcat(all_half_first,half_first);
            all_half_sec=strvcat(all_half_sec,half_sec);
        end
        imgmat.fname=fullfile(root_first,'Avg_of_first_half.nii');
        V_first=spm_imcalc(spm_vol(all_half_first),imgmat,'sum(X)/size(X,1)',{1,0,0});  
        imgmat.fname=fullfile(root_first,'Avg_of_sec_half.nii');
        V_sec=spm_imcalc(spm_vol(all_half_sec),imgmat,'sum(X)/size(X,1)',{1,0,0});  
        imgmat.fname=fullfile(root_first,'Diff_of_first_sec_half.nii');
        V_diff_half=spm_imcalc(spm_vol(strvcat(V_first.fname,V_sec.fname)),imgmat,'i1-i2',{0,0,0});  
        FG_enhanced_spm_check_registration(strvcat(V_first.fname,V_sec.fname,V_diff_half.fname))
 











     if nargin==0 || nargin==1 
        write_name=fullfile(root_first,'quality_control_report.txt');
     end
     
     dlmwrite(write_name,'         ', '-append',  'delimiter', '', 'newline','pc');
     dlmwrite(write_name,['---report for:' root_dir], '-append',  'delimiter', '', 'newline','pc'); 
     dlmwrite(write_name,'         ', '-append',  'delimiter', '', 'newline','pc');

% get and check the motion parameters of a series of images
    [all_idx,motion_idx,intensity_idx]=FG_art_approximate_motion_judge(fun_imgs,root_first);
    saveas(gcf,fullfile(root_first,'1_Snap_motion.bmp'))
    if nargin~=0, close (gcf); end
    pause(0.01)  % release the memory to close the figure

%%
% close(pfig)

    if isempty(motion_idx)
        fprintf('---- No sudden motion outliers need to be concerned...\n')  
        dlmwrite(write_name,'---- No sudden motion outliers need to be concerned...', '-append',  'delimiter', '', 'newline','pc'); 
    elseif length(motion_idx)<0.1*size(fun_imgs,1)
        fprintf('---- Ignore few sudden motion outliers: %s \n',num2str(motion_idx))
        dlmwrite(write_name,['---- Ignore few sudden motion outliers: ' num2str(motion_idx)], '-append',  'delimiter', '', 'newline','pc'); 
    else
        fprintf('---- Remove sudden motion outliers: %s \n',num2str(motion_idx))
        dlmwrite(write_name,['---- Remove sudden motion outliers: ' num2str(motion_idx)], '-append',  'delimiter', '', 'newline','pc'); 
       % get the corresponding image pairs (default: ASL data are acquired in a control-label way)
       % if it is reverse, change the label_way value into 0;
       label_way=1; % control--->label order
       [motion_pair,unique_pairs]=FG_get_corresponding_pair_img(motion_idx,label_way) ; 
       fprintf('\n---- All discarded images are: %s \n',num2str(unique_pairs'))
       dlmwrite(write_name,['---- All discarded images are: ' num2str(unique_pairs')], '-append',  'delimiter', '', 'newline','pc'); 
       fun_imgs(unique_pairs',:)=[]; %% delete all the motion outliers
    end
    
    
% manipulate the even and odd images
    OE_outs=FG_singledir_imgs_cal_avgODD_and_even_separately(fun_imgs,root_first);  %%% all outputs will be in the same folder as the first image
        % %     % files in the OE_outs:
        % %         % 1.avg_odd
        % %         % 2.avg_even
        % %         % 3.Difference_Odd_Even
        % %         % 4.Difference_Even_Odd
        % %         % 5.Average of all
        
%     for i=[3 4 5]
%         delete (deblank(OE_outs(i,:)))
%     end


% show the gradient signal of the horizonal plane at central plane
    %     FG_gradient_value_of_a_plane(FG_read_vols(OE_outs(1,:)),0,0.75)


    maskY1=FG_get_SPM_TMVV_and_TMVV_based_mask(FG_read_vols(OE_outs(1,:)),0.05,0.1); % 0.08-0.4 TMVV can be used to extract the potential signal out of the skull (artifact)
    FG_write_vol(imgmat,maskY1,fullfile(root_first,'SPM_potential_artifact.nii'));
    maskY1=imerode(maskY1,strel('square',3)); % erode the potential small parts within the skull
    maskY1_labeled=FG_delete_small_clusters(maskY1,0.35);
    FG_write_vol(imgmat,maskY1_labeled,fullfile(root_first,'SPM_artifact_ROIs.nii'));
    art_ROIs=FG_save_multilabeled_ROI_or_clusters_into_pieces(fullfile(root_first,'SPM_artifact_ROIs.nii'),1);
    fprintf('\n---- Totally %s artifact ROIs were detected preliminarily...\n',num2str(size(art_ROIs,1)))
    dlmwrite(write_name,['---- Totally ' num2str(size(art_ROIs,1)) ' artifact ROIs were detected prelimiarily',], '-append',  'delimiter', '', 'newline','pc'); 

%%%%% 
%%%%% %%%%% 
%%%%%  deal with the situation that not artifact ROI is found
%%%%% %%%%% 
%%%%% 
    
    maskY2=FG_get_SPM_TMVV_and_TMVV_based_mask(FG_read_vols(OE_outs(1,:)),0.55);   % 0.55 TMVV is a quite good threshold to extract the whole brain with skull
    FG_write_vol(imgmat,maskY2,fullfile(root_first,'SPM_brain.nii'));
%     FG_fill_inside_Graymatter(fullfile(root_first,'SPM_brain.nii'),1)
    
    maskY3=FG_get_SPM_TMVV_and_TMVV_based_mask(FG_read_vols(OE_outs(1,:)),0.5,0.8);   %% 0.45-0.8TMVV can be used to extract the skull of the brain
%     maskY3=imopen(smooth3(maskY3,'box',1),strel('square',1)); % erode the potential small parts within the skull
    maskY3=FG_delete_small_clusters(maskY3,0.30);
    FG_write_vol(imgmat,maskY3>0,fullfile(root_first,'SPM_skull.nii'));
    
    
    maskY2=FG_get_SPM_TMVV_and_TMVV_based_mask(FG_read_vols(OE_outs(1,:)),0.01,0.20);   % 0.55 TMVV is a quite good threshold to extract the whole brain with skull
    FG_write_vol(imgmat,maskY2,fullfile(root_first,'SPM_background.nii'));
%     FG_fill_inside_Graymatter(fullfile(root_first,'SPM_brain.nii'),1)
    
    FG_enhanced_spm_check_registration(strvcat( fullfile(root_first,'SPM_potential_artifact.nii') ,...  
                                                fullfile(root_first,'SPM_artifact_ROIs.nii') ,...
                                                fullfile(root_first,'SPM_brain.nii') ,...
                                                fullfile(root_first,'SPM_background.nii') ,...
                                                fullfile(root_first,'SPM_skull.nii')));
    % save the SPM-dispaly picture
    saveas(gcf,fullfile(root_first,'2_Snap_artifact_relateds.bmp'))
    close gcf
 
    
    
    
    
    
    
    
    
    
    
%% for the fat artifact detectation
%     % read the mean/SD of the signal within the 'SPM_background.nii' area
%       [TC,TC_mean,TC_std,varargout]=get_timecourse(fun_imgs,fullfile(root_first,'SPM_background.nii'))  ;
%       masked_AvgedAll=mask_out_areas_outside_ROI(deblank(OE_outs(5,:)),fullfile(root_first,'SPM_background.nii'),root_first) ; 
%     %   masked_funs=mask_out_areas_outside_ROI(fun_imgs,fullfile(root_first,'SPM_background.nii'),root_first) ; 
% 
%         for i=1:4
%             imgmat.fname=fullfile(root_first,['Thresholded_' num2str(i) 'SD_masked_AvgedAll.nii']);
%             spm_imcalc(spm_vol(masked_AvgedAll),imgmat,['(i1>' num2str(i*TC_std*15) ').*i1'],{0,0,0});
% 
%         end
% 
%         FG_enhanced_spm_check_registration(strvcat( fullfile(root_first,'SPM_background.nii') ,...  
%                                                     fullfile(root_first,['Thresholded_1SD_masked_AvgedAll.nii']) ,...  
%                                                     fullfile(root_first,['Thresholded_2SD_masked_AvgedAll.nii']) ,...
%                                                     fullfile(root_first,['Thresholded_3SD_masked_AvgedAll.nii'])));
%     % threshold the signal with TC_std which got above
  
    

%%%%%%%%%%%%%%% dealing with the background_masked images
%%%%%%%%%%%%%%%%%%%%%%%%
    background_only_imgs=[];
    for i=1:size(fun_imgs,1)
        imgmat.fname=fullfile(root_first,['BackgroundOnly_' num2str(i) '_.nii']);
        background_only_imgs=strvcat(background_only_imgs,imgmat.fname);
        spm_imcalc(spm_vol(strvcat(fullfile(root_first,'SPM_background.nii'),deblank(fun_imgs(i,:)))),imgmat,['i1.*i2'],{0,0,0});
    end
    Ivol=spm_read_vols(spm_vol(background_only_imgs));  % read the 4D volumes
    [x,y,z,T]=size(Ivol);
    figure('Name','one slice of a volume of an image...');
    subplot(3,1,1);
    imshow(Ivol(:,:,10,4),[])
   % crop out (select) the front/back part(1/3 y-axis) of the brain to reduce
   % data, because we are clear about the location of the potential artifact
   
   % back 1/3
   Ivol1=Ivol(:,1:y*1/3,:,:);
   [x,y1,z,T]=size(Ivol1);
   subplot(3,1,2);
   imshow(Ivol1(:,:,10,4),[])
   % front 1/3
    Ivol2=Ivol(:,y*2/3:y,:,:);
    [x,y2,z,T]=size(Ivol2);
    subplot(3,1,3);
    imshow(Ivol2(:,:,10,4),[])
    
    V=reshape(Ivol2,[x*y2*z,T]);
    % remove all the zero voxels
    tem=[];
    for i=1:x*y2*z
        if isempty(find(V(i,:)~=0))
            tem=[tem, i];
        end
    end
    V_new=V;
    V_new(tem,:)=[];
 
  %% Use the judgement of smallest variance & largest mean of timecourse
  Means=mean(V_new')';
  Stds=std(V_new')';
  Mean_filter=5*std(Means);
  Std_filter=5*mean(Stds);  
  
  mean_voxs=find(Means>Mean_filter);
  std_voxs=find(Stds>Std_filter);
  if length(mean_voxs)>length(std_voxs)
      found=ismember(std_voxs,mean_voxs)  ;
  elseif length(std_voxs)>length(mean_voxs)
      found=ismember(mean_voxs,std_voxs);
  end
   
  a=std_voxs(found(found==1));
  potential_voxs_TC=V_new(a,:);
  figure('Name','timecourse of all & potential & selected voxels...');
  subplot(3,1,1);
  plot(1:size(V_new,2),V_new)
  subplot(3,1,2);
  plot(1:size(potential_voxs_TC,2),potential_voxs_TC)

  %% Use the judgement of the correlation of the timecourses
  [Rs,Ps]=corrcoef(potential_voxs_TC');
  Rs_of_Artifact_ROIs=FG_set_half_diagonal_matrix_into_n(Rs,0,'below'); 
  [a,b]=find(Rs_of_Artifact_ROIs>0.95); %% do we need to constrain their should be not less than 2 pairs?
    if isempty(a)
        fprintf('\n---- Correlations between Artifact ROIs are low. That indicated no need to care about the artifact...\n')
    else
        selected_ROIs=unique([a;b]');
        fprintf('\n---- No. %s ROIs''s timecourse were selected and averaged as the representive artifact timecouse ...\n',num2str(selected_ROIs))
        selected_TCs=potential_voxs_TC(selected_ROIs',:);
        subplot(3,1,3);
        plot(1:size(selected_TCs,2),selected_TCs)
        artifact_TC=mean( selected_TCs,1);
    end   
   FG_show_correlation_matrix(Rs_of_Artifact_ROIs);











    
    
    
%% for the phase artifact area detectation    
%             % draw the timecourses of the potential artifact ROIs to evaluate    
%                 All_TCs=[];
%                 for i=1:size(art_ROIs,1)
%                     [TC,TC_mean,TC_std,varargout]=get_timecourse(fun_imgs,deblank(art_ROIs(i,:)))  ;
%                     All_TCs=[All_TCs,TC];
%                 end
%                 FG_simple_plot_fig(All_TCs,'All potential artifact ROI''s timecourse...',0);
%                 saveas(gcf,fullfile(root_first,'3_Snap_artifact_ROI_timecourses.bmp'))   
%                 if nargin~=0, close (gcf); end
%                 pause(0.01)  % release the memory to close the figure
% 
%                 [Rs,Ps]=corrcoef(All_TCs);
%                 Rs_of_Artifact_ROIs=FG_set_half_diagonal_matrix_into_n(Rs,0,'below');
%                 FG_show_correlation_matrix(Rs_of_Artifact_ROIs);
%                 saveas(gcf,fullfile(root_first,'4_Snap_artifact_ROI_correlation_matrix.bmp'))
%                 if nargin~=0, close (gcf); end
%                 pause(0.01)  % release the memory to close the figure
% 
%             % based on the correlation coefficients to choose representive ROIs as the artifact
%                 [a,b]=find(Rs_of_Artifact_ROIs>0.75); %% do we need to constrain their should be not less than 2 pairs?
%                 if isempty(a)
%                     fprintf('\n---- Correlations between Artifact ROIs are low. That indicated no need to care about the artifact...\n')
%                     dlmwrite(write_name,'---- Correlations between Artifact ROIs are low. That indicated no need to care about the artifact...', '-append',  'delimiter', '', 'newline','pc'); 
%                     return
%                 else
%                     selected_ROIs=unique([a;b]');
%                     fprintf('\n---- No. %s ROIs''s timecourse were selected and averaged as the representive artifact timecouse ...\n',num2str(selected_ROIs))
%                     dlmwrite(write_name,['---- No. ' num2str(selected_ROIs)  ' ROIs''s timecourse were selected and averaged as the representive artifact timecouse'], '-append',  'delimiter', '', 'newline','pc'); 
%                     selected_TCs=All_TCs(:,selected_ROIs);
%                     artifact_TC=mean( selected_TCs,2);
%                     % write out the selected ROIs
%                     final_art_name=fullfile(root_first,'SPM_selected_artifact_ROIs.nii');
%                     imgmat.fname=final_art_name;
%                     spm_imcalc(spm_vol(art_ROIs(selected_ROIs,:)),imgmat,'sum(X)/size(X,1)',{1,0,0});  
%                 end  
% 
%              % evaluate the correlation between artifact timecourse and zig-zag of ASL
%                 zigzag=ones(size(artifact_TC));
%                 zigzag(1:2:end,1)=-1;
%                 [r,p]=corr(artifact_TC,zigzag);
%                 if abs(r)<0.5 && p>0.05
%                     fprintf('\n---- zig-zag timecourse is not correlated with artifact signal(r=%s, p=%s)..\n',num2str(r),num2str(p))
%                     dlmwrite(write_name,['---- zig-zag timecourse is not correlated with artifact signal(r=' num2str(r) ', p=',num2str(p) ')'], '-append',  'delimiter', '', 'newline','pc'); 
%                 else
%                     fprintf('\n---- zig-zag timecourse seems correlated with artifact signal(r=%s, p=%s)..\n',num2str(r),num2str(p))
%                     dlmwrite(write_name,['---- zig-zag timecourse seems correlated with artifact signal(r=' num2str(r) ', p=',num2str(p) ')'], '-append',  'delimiter', '', 'newline','pc');
%                     return
%                 end
%             %%%%% 
%             %%%%% %%%%% 
%             %%%%%  deal with the situation that not artifact ROI is found
%             %%%%% %%%%% 
%             %%%%% 
% 
% 
% 
%             % evaluate the artifact in the even & odd images
%                 % get the timecouse of the selceted voxles in the artifact image
%                 [TC_odd,TC_mean_odd,TC_std_odd]=get_timecourse(fun_imgs(1:2:end,:),final_art_name);
%                 [TC_even,TC_mean_even,TC_std_even]=get_timecourse(fun_imgs(2:2:end,:),final_art_name);
%                 [r_odd_even,p_odd_even]=corr(TC_odd,TC_even);
%                 fprintf('\n....The correlation of even-odd images of artifact signal is r=%s, p=%s !\n',num2str(r_odd_even),num2str(p_odd_even))
%                 % plot the time course
%                 fig_name=fullfile(root_first,['Odd-Even -r ',num2str(r_odd_even,'%10.3f'),' -p ' ,num2str(p_odd_even,'%10.3f')]);
%                 plot_Timecourses([TC_odd,TC_even,TC_odd-TC_even],fig_name);
%                 saveas(gcf,fullfile(root_first,['5_Snap_Odd-Even -r ',num2str(r_odd_even,'%10.3f'),' -p ' ,num2str(p_odd_even,'%10.3f'), '.bmp']))
%                 if nargin~=0, close (gcf); end
%                 pause(0.01)  % release the memory to close the figure
% 
%                 % judge whether to correct the images or not
%                 tem=(abs(TC_odd-TC_even))>5;
%                 n_outlier=length(find(tem));
%                 if  n_outlier<3
%                     fprintf('\n.... Artifact of images may be serious, suggest to do the correction!\n')
%                     dlmwrite(write_name,'.... Artifact of images may be serious, suggest to do the correction!', '-append',  'delimiter', '', 'newline','pc');
% 
%                 else
%                     fprintf('\n.... Artifact of images are not that serious, suggest not to do the correction!\n')   
%                     dlmwrite(write_name,'.... Artifact of images are not that serious, suggest not to do the correction! Exit', '-append',  'delimiter', '', 'newline','pc');
%                     return
%                 end    
% 
%             % do connectivity and do the image correction job for the Odd images
%                 mask_brain=FG_get_SPM_TMVV_and_TMVV_based_mask(FG_read_vols(OE_outs(1,:)),0.48);   % 0.55 TMVV is a quite good threshold to extract the whole brain with skull
%                 FG_write_vol(imgmat,mask_brain,fullfile(root_first,'SPM_brain_mask_odd.nii'));
%                 [h_feedback,thresholded_r_name1]=voxel_wised_correlation_and_correction(fun_imgs(1:2:end,:),TC_odd,mask_brain,'odd');
%                 if strcmpi(h_feedback,'cancel'),  return ;  end
% 
%                 % show the images
%                 FG_enhanced_spm_check_registration(strvcat(fullfile(root_first,['Ref_whole_r_odd.nii']),thresholded_r_name1,fullfile(root_first,['Ref_r_corrected_areas_odd.nii'])));
%                 saveas(gcf,fullfile(root_first,['6_Snap_r_related_pics_odd.bmp']))
%                 if nargin~=0, close (gcf); end
%                 pause(0.01)  % release the memory to close the figure
% 
% 
%             % do connectivity and do the image correction job for the Even images
%                 mask_brain=FG_get_SPM_TMVV_and_TMVV_based_mask(FG_read_vols(OE_outs(2,:)),0.48);   % 0.55 TMVV is a quite good threshold to extract the whole brain with skull
%                 FG_write_vol(imgmat,mask_brain,fullfile(root_first,'SPM_brain_mask_odd.nii'));
%                 [h_feedback,thresholded_r_name2]=voxel_wised_correlation_and_correction(fun_imgs(2:2:end,:),TC_even,mask_brain,'even');
%                 if strcmpi(h_feedback,'cancel'),  return ;  end
% 
%                 % show the images
%                 FG_enhanced_spm_check_registration(strvcat(fullfile(root_first,['Ref_whole_r_even.nii']),thresholded_r_name2,fullfile(root_first,['Ref_r_corrected_areas_even.nii'])));
%                 saveas(gcf,fullfile(root_first,['7_Snap_r_related_pics_even.bmp']))
%                 if nargin~=0, close (gcf); end
%                 pause(0.01)  % release the memory to close the figure
% 
%                % the difference of odd-even thresholded r-maps
%                 diff_rmap_name=fullfile(root_first,'Ref_diff_r_map.nii');
%                 imgmat.fname=diff_rmap_name;
%                 spm_imcalc(spm_vol(strvcat(thresholded_r_name1,thresholded_r_name2)),imgmat,'i1-i2',{0,0,0});  
% 
% 
%                 FG_enhanced_spm_check_registration(strvcat(thresholded_r_name1,thresholded_r_name2,diff_rmap_name));
%                 saveas(gcf,fullfile(root_first,'8_Snap_r_diff_areas_odd_even.bmp'))
%                 if nargin~=0, close (gcf); end
%                 pause(0.01)  % release the memory to close the figure
   
    % do connectivity and do the image correction job for the all functional images
    
    
%     background_only_imgs=[];
     for i=1:size(fun_imgs,1)
        imgmat.fname=fullfile(root_first,['BackgroundOnly_' num2str(i) '_.nii']);
%         background_only_imgs=strvcat(background_only_imgs,imgmat.fname);
        spm_imcalc(spm_vol(strvcat(fullfile(root_first,'SPM_background.nii'),deblank(fun_imgs(i,:)))),imgmat,['i1.*i2'],{0,0,0});
    end   
    
    
        mean_mask_background=fullfile(root_first,['mean_BackgroundOnly.nii']);
        spm_imcalc_ui(background_only_imgs,mean_mask_background,'sum(X)~=0',{1,0,16,0})
        mask_brain=logical(spm_read_vols(spm_vol(mean_mask_background)));   % 0.55 TMVV is a quite good threshold to extract the whole brain with skull
        FG_write_vol(imgmat,mask_brain,fullfile(root_first,'SPM_brain_mask_all.nii'));
        [h_feedback,thresholded_r_name1]=voxel_wised_correlation_and_correction(background_only_imgs,artifact_TC',mask_brain,'all');
        if strcmpi(h_feedback,'cancel'),  return ;  end

        % show the images
        FG_enhanced_spm_check_registration(strvcat(fullfile(root_first,['Ref_whole_r_all.nii']),thresholded_r_name1,fullfile(root_first,['Ref_r_corrected_areas_all.nii'])));
        saveas(gcf,fullfile(root_first,['6_Snap_r_related_pics_all.bmp']))
        if nargin~=0, close (gcf); end
        pause(0.01)  % release the memory to close the figure




% all are done~        
   
    fprintf('\n........Images are corrected! All set!\n')   
    dlmwrite(write_name,'.... Images are corrected!', '-append',  'delimiter', '', 'newline','pc');
    fprintf('\n.... All done......\n')   



    
    
    
    
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%% Subfunctions  %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [h_feedback,thresholded_r_name]=voxel_wised_correlation_and_correction(fun_imgs,TC_all,mask_brain,subfix)
%% Voxel-wise correlation (connectivity)
%% make voxel-wised time-course correlation with the ROI_artifact 
%% time course to separate all the suspected artifact voxels
% all_V is a 4D-volume matrix
% split matrix into several sessions to do the voxel-wised correlation to
% avoid out-of-memory problem (step=10000)
imgmat=spm_vol(deblank(fun_imgs(1,:)));

    [root_dir,b,c,d]=fileparts(deblank(fun_imgs(1,:))); 
    [root_pth,root_sub]=FG_sep_group_and_path(deblank(root_dir));    
    root_first=[root_pth,root_sub '_corrected'];
    if ~exist(root_first,'dir')
        mkdir (root_first);
    end

all_V_real=FG_read_vols(fun_imgs); 
all_V_real(isnan(all_V_real))=0; % reset all the NaN values into 0

all_V_tem=all_V_real; % use to evaluate the whole brain including the potential noise areas
all_V_tem=reshape(all_V_tem,[prod(imgmat.dim),size(fun_imgs,1)]);
all_V_tem=all_V_tem';
    
    
all_r=[];
% all_p=[];
global h_waitbar_state;  %% be careful: the global announcement
h_waitbar_state=0;
starttime=clock;
h_wait=waitbar(1/size(all_V_tem,2),['Voxelwised correlation(' subfix '): 0%'],'CreateCancelBtn','global h_waitbar_state; h_waitbar_state=1;');
% h_wait=waitbar(0.01,'Voxel-wised correlation ...');   %% introduce the cancel callback~~~ %% be careful: the global announcement
% FG_progressbar('Voxel-wised correlation ...');
step=1000;
for i=1:step:size(all_V_tem,2)
%     [Rs,Ps] = corr(TC_all,all_V_tem(:,i)) ;
   if i+step-1>size(all_V_tem,2)
       next_end=size(all_V_tem,2);
   else
       next_end=i+step-1;
   end       
       
    tem=[TC_all,all_V_tem(:,i:next_end)];
    [Rs ,Ps]= corrcoef(tem) ;
%     all_p=[all_p;Ps];
    all_r=[all_r;Rs(1,2:end)'];    

    if rem(next_end,4000)==0
        fractiondone=i/size(all_V_tem,2);
        waitbar(i/size(all_V_tem,2),h_wait,['Voxelwised correlation(' subfix '): ' FG_update_remaining_time(fractiondone,starttime)]);
        pause(0.001)
    elseif next_end==size(all_V_tem,2)
        fractiondone=i/size(all_V_tem,2);
        waitbar(i/size(all_V_tem,2),h_wait,['Voxelwised correlation(' subfix '): ' FG_update_remaining_time(fractiondone,starttime)]);        
        pause(0.001)
    end
    
%% Set up the canceling callback~~~
    pause(0.01)
    if h_waitbar_state 
        spm_figure('Close',allchild(0)) %% close all figures
        h_feedback='cancel';
        thresholded_r_name=[];
    	return;
    end
end
clear Rs Ps tem % clear the huge memory
delete(h_wait);
pause(0.01)
clear h_waitbar_state h_wait


all_r=reshape(all_r(:),[size(all_V_real,1) size(all_V_real,2) size(all_V_real,3)]);
% all_p=reshape(all_p(:),[size(all_V_real,1) size(all_V_real,2) size(all_V_real,3)]);
imgmat.fname=fullfile(root_first,['Ref_whole_r_' subfix '.nii']);
spm_write_vol(imgmat,all_r);

all_thresd_r=all_r.*(all_r>=0.45);
thresholded_r_name=fullfile(root_first,['Ref_whole_thresholded_r_' subfix '.nii']);
imgmat.fname=thresholded_r_name;
spm_write_vol(imgmat,all_thresd_r);


%% correction method 1
%             % mask out the detected artifact areas  ----- this is ridiculous
%                 for i=1:size(fun_imgs,1)
%                     [a1,b1,c1,d1]=fileparts(deblank(fun_imgs(i,:)));
%                     tem=all_V_real(:,:,:,i);
%                     V_last=tem.*(all_thresd_r==0);
% 
%                     imgmat.fname=fullfile(a1,['Ref_corrected_' b1  '.nii']);
%                     spm_write_vol(imgmat,V_last);
%                 end


%% correction method 2
% regress out the artifact signal of the detected artifact areas
    clear all_V_tem
    mask_brain1=repmat(mask_brain,[1,1,1,size(fun_imgs,1)]); 
    all_V_real=all_V_real.*mask_brain1;  % mask out the non-brain areas to generate the real brain without background noise
                                          % used this all_V_real values in the
                                          % last correction session                                      
    all_V_tem=reshape(all_V_real,[prod(imgmat.dim),size(fun_imgs,1)]);
    all_V_tem=all_V_tem'; % e.g. size is 40*184320

    whole_corrected_area=(mask_brain.*all_thresd_r)>0;
    FG_write_vol(imgmat,whole_corrected_area,fullfile(root_first,['Ref_r_corrected_areas_' subfix '.nii']));

    ROI_mask=whole_corrected_area(:)'; %  e.g. size is 1*184320, used to select voxles to do regresssion
    
    fprintf('\n  Reconstructing images....\n')
    
    for i=1:length(ROI_mask)
        if ROI_mask(i)==1     
           y=all_V_tem(:,i);
          [beta,bint,residual]=regress(y,TC_all);
          all_V_tem(:,i)=residual;
        end        
    end
    
    [root_dir,b,c,d]=fileparts(deblank(fun_imgs(1,:))); 
    [root_pth,root_sub]=FG_sep_group_and_path(deblank(root_dir));    
    root_first=[root_pth,root_sub '_corrected'];
    if ~exist(root_first,'dir')
        mkdir (root_first);
    end
    
    % write out the corrected images
    all_V_tem=all_V_tem'; % be careful, turn the matrix back properly before out reshape the matrix
    all_V_last=reshape(all_V_tem,[size(all_thresd_r,1),size(all_thresd_r,2),size(all_thresd_r,3),size(fun_imgs,1)]);
    for i=1:size(fun_imgs,1)
        [a1,b1,c1,d1]=fileparts(deblank(fun_imgs(i,:)));
        [root_pth,root_sub]=FG_sep_group_and_path(deblank(a1)); 
        root_first=[root_pth,root_sub '_corrected'];
        if ~exist(root_first,'dir')
            mkdir (root_first);
        end
        FG_write_vol(imgmat,all_V_last(:,:,:,i),fullfile(root_first,['Ref_corrected_' b1  '.nii']));
        FG_write_vol(imgmat,all_V_real(:,:,:,i),fullfile(root_first,['Ref_masked_' b1  '.nii']));
    end

h_feedback='Going on';















% plot the two TCs
function plot_Timecourses(TC,fig_name)
    % plot TC (matrix) in columns
if size(TC,1)>=2
   h=figure('name',fig_name); 
   line_color=[1 0 1];
   edge_color=[0.5 0.5 1];
   axes('position',[.2  .1  .7  .8]) % adjust the image 
   for i=1:size(TC,2)                
        
        t_min=min(TC(:));
        t_max=max(TC(:));

        if isnan(t_min) || isnan(t_max) 
            return                   
        elseif t_min==t_max
            t_max=t_max*2;
        end    

        xlim([1,size(TC,1)+1]);
        ylim([t_min,t_max+5]);        
        
        set(gca,'XTick',[1:2:size(TC,1)+1]);
        set(gca,'YTick',[t_min:2*ceil((t_max-t_min)/size(TC,1)):t_max+5]);
        grid(gca,'on')                 
        
        
        Seeds(i)=rand(1);
        if i>1
           if Seeds(i)-Seeds(i-1)<0.01
               Seeds(i)=Seeds(i)+0.2;
           end
        end
        randSeed=Seeds(i);

        tem_line_color=randSeed*line_color/i;
        line([1:size(TC(:,i),1)],TC(:,i),'Color',tem_line_color,'LineStyle','-','Marker','o','LineWidth',2,...
        'MarkerEdgeColor',randSeed*edge_color/i,...
        'MarkerFaceColor',randSeed*0.5*edge_color/i,...
        'MarkerSize',3);  
        hold on;
        plotMean(TC(:,i),tem_line_color); 
        
%         text(size(TC(:,i),1),TC(end,i),['\leftarrow TC(' num2str(i), ')' ],'HorizontalAlignment','left','color',tem_line_color);
        pos_max=find(TC(:,i)==max(TC(:,i)));
        pos_min=find(TC(:,i)==min(TC(:,i)));
        max_tc=max(TC(:,i));
        min_tc=min(TC(:,i));
        text(length(TC(:,i)),TC(end,i),['\leftarrow TC(' num2str(i) '), ranges(' num2str(min_tc) ' ~ ' num2str(max_tc) ')'],'HorizontalAlignment','left','color',tem_line_color);

   end
end
% saveas(h,[fig_name '.bmp'])
% % close (h)



%% a subfunction to draw the mean line
function plotMean(TC,tem_line_color)
    xlimits = get(gca,'XLim');
    meanValue = mean(TC);
    if isnan(meanValue)
       fprintf('\n-----Warning: your values may have NaN values, the blue mean line is based on the Non-NaN values!--------------\n')
       meanValue = mean(TC(find(~isnan(TC))));
    end
    line([xlimits(1) xlimits(2)],[meanValue meanValue],'Color',tem_line_color,'LineStyle','-.');


% subfunction
function [TC,TC_mean,TC_std,varargout]=get_timecourse(images,ROI)    
    Rmat=spm_vol(ROI);
    R=spm_read_vols(Rmat);
    R=logical(R); % mask sure it is binary
    TC=[];
    all_V=zeros(Rmat.dim(1),Rmat.dim(2),Rmat.dim(3),size(images,1));
    for i=1:size(images,1)
        Vmat=spm_vol(images(i,:));
        V=spm_read_vols(Vmat);
        all_V(:,:,:,i)=V;
        voxel_vals=V(R);
        TC(i,1)=mean(voxel_vals(voxel_vals>0));        
    end
    
    TC_mean=mean(TC(:));
    TC_std=std(TC(:));

if nargout>3
    varargout={all_V};
end


% subfunction
function masked_funs=mask_out_areas_outside_ROI(images,ROI,root_first)    
    [R,Rmat]=FG_read_vols(ROI);
    R=double(logical(R)); % mask sure it is binary
    [V,Vmat]=FG_read_vols(images);
    mask_4D=repmat(R,[1,1,1,size(V,4)]);
    masked_V=V.*mask_4D;
    masked_funs=[];
    for i=1:size(images,1)
        [a,b]=FG_separate_files_into_name_and_path(deblank(images(i,:)));        
        FG_write_vol(Vmat(i),masked_V(:,:,:,i),fullfile(root_first,['masked_' b]))   ;   
        masked_funs=strvcat(masked_funs,fullfile(root_first,['masked_' b]));
    end

