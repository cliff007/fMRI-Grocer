function FG_native_space_batch_rois_mat2nifity_marsbar_based_Trash
% J Grahn
% MarsBaR batch script to convert roi format to image format(including nii and img/hdr pair)
%% See http://marsbar.sourceforge.net

% this script can just create ROI image in the ROI native space.
% Please note the difference between "ROI native space" and "Based space for ROI"

%%%%%% http://imaging.mrc-cbu.cam.ac.uk/imaging/MarsBar

   addpath(fullfile(FG_rest_misc('WhereIsREST'), 'rest_spm5_files')); % need to utilize REST

   %roi_dir = '/jet/szhu/fmri_related/ROIs_Templates/marsbar-aal-0.2'; %Directory with ROIs to convert

% select the directory where the ROIs(.mat) is in
  if strcmp(spm('ver',[],1),'SPM5')|strcmp(spm('ver',[],1),'SPM8')
       roi_dir = spm_select(1,'dir','Select the directory where the ROIs(.mat) is in:', [],pwd);
  else  
       roi_dir = spm_get(1,'dir','Select the directory where the ROIs(.mat) is in:'); 
  end
    if isempty(roi_dir)
      return
    end 

cd (roi_dir)

   if strcmp(spm('ver',[],1),'SPM5')|strcmp(spm('ver',[],1),'SPM8')
       roi_mats = spm_select(Inf,'.mat','Select the ROIs(.mat) files:', [],pwd);
  end
    if isempty(roi_mats)
      return
   end   
    
    
% MarsBaR version check
if isempty(which('marsbar'))
  error('Need MarsBaR on the path');
end
v = str2num(marsbar('ver'));
if v < 0.35
  error('Batch script only works for MarsBaR >= 0.35');
end
spm('defaults', 'fmri');
marsbar('on');  % needed to set paths etc

% %For a single, named ROI
% roi_name = fullfile(roi_dir, 'MNI_Putamen_L_roi.mat');
% roi_array{1} = maroi(roi_name);
% 
% for roi_no = 1:length(roi_array)
%    roi = roi_array{roi_no};
% save_as_image(roi, fullfile(roi_dir, 'test.nii'))
% end

%For batch converting the contents of a directory of ROIs
% roi_namearray = dir(fullfile(roi_dir, '*_roi.mat'));
roi_namearray =roi_mats;
roi_namearray=spm_str_manip(roi_namearray,'dc');  % take use of the "spm_str_manip" function

    if size(roi_namearray,1)==1   % in this condition, [spm_str_manip(spm_str_manip(roi_namearray,'dh'),'dc')] can't get the group dirctories
       i=size(roi_namearray,2); 
       success=0;
       for j=i:-1:1
           if roi_namearray(j)==filesep
               success=1;
               break
           end
       end
       if success==1
           roi_namearray=roi_namearray(j+1:end);
       end
    end
    
    
for roi_no = 1:size(roi_namearray,1)
    roi_array{roi_no} = maroi(fullfile(roi_dir, deblank(roi_namearray(roi_no,:))));
    roi = roi_array{roi_no};
    name = strtok(deblank(roi_namearray(roi_no,:)), '.');
    save_as_image(roi, fullfile(roi_dir, [name '.nii']));

   %% use REST functions to convert the .nii files into img pairs
        [Data, Head] = FG_rest_ReadNiftiImage(fullfile(roi_dir, [name '.nii']));
        Head.n=[1 1];
        PO = fullfile(roi_dir, [name '.nii']);
        [Path, fileN, extn] = fileparts(PO);
        POout=[Path,filesep,fileN,'.img'];
        FG_rest_WriteNiftiImage(Data,Head,POout);
    % eval(['delete ''' fname '''']) % delete all the tempporal .nii files if you want


end
fprintf('\n-----Hi, we are done~~~~~~~~\n')
