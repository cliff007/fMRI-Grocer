function FG_batch_MNI2SphereROI_build_marsbar_based
% MarsBaR batch script to make ROIs
% this batch file takes a list of coordinates and makes sphere ROIs, saving them in MarsBar .nii and hdr/img pair format. 
%% http://imaging.mrc-cbu.cam.ac.uk/imaging/MarsBar
%Adapted by J Grahn

addpath(fullfile(FG_rest_misc('WhereIsREST'), 'rest_spm5_files')); % need to utilize REST

% MarsBaR version check
if isempty(which('marsbar'))
  error('Need MarsBaR on the path');
end
v = str2num(marsbar('ver'));
if v < 0.35
  error('Batch script only works for MarsBaR >= 0.35');
end

% Set up the SPM defaults, just in case
spm_get_defaults;  %% important
spm('defaults', 'fmri');

marsbar('on');  % needed to set paths etc


%Optional: this is a list of coordinates from which Marsbar will make
%sphere ROIs. You can specify details of each ROI separately instead of
%using a list like this (look at commented out script below the for:end
%loop.
    %    sphere_centres = [-6 6 54; 6 3 63; 6 15 48]

% select the .txt file that contain all the sphere coordinate (as below)
        % coordinate.txt  (if your file is .mat format, please load and save as .txt first, sorry!)
            % the coordinates it contain is as below( a group of x/y/z(mm) each line)
            %      1     2     3
            %      4     5     6
            %     -1    -2    -3
  if strcmp(spm('ver',[],1),'SPM5')||strcmp(spm('ver',[],1),'SPM8')
       coord_txt = spm_select(1,'.txt','Select the txt file where the MNI coordinates are in:', [],pwd,'.*txt');
       eval(['sphere_centres=load(''' coord_txt ''');']);
  end
  
 
  
    dlg_prompt={'Specify the sphere radius of the ROI you want to create:'};
    dlg_name='Sphere radius...';
    dlg_def={'10'};
    Ans=inputdlg(dlg_prompt,dlg_name,1,dlg_def,'on');   



 % select the root directory where to store the final ROIs(.mat) is in
  if strcmp(spm('ver',[],1),'SPM5')|strcmp(spm('ver',[],1),'SPM8')
       root_dir = spm_select(1,'dir','Select the directory where to store the output files(.mat/nii/img)', [],pwd);
  end
  
  if isempty(root_dir),return;end

  cd(root_dir)
%Make sphere ROIs from list given above.
for x = 1:size(sphere_centres,1)
area =['ROI' ]
sphere_centre = sphere_centres(x,:)
sphere_radius = str2num(Ans{1})  % the radius of the sphere you need
sphere_roi = maroi_sphere(struct('centre', sphere_centre, 'radius', sphere_radius));
% Give it a name
details = [area '_' int2str(sphere_centre(1)) '_' int2str(sphere_centre(2)) '_' int2str(sphere_centre(3)) '_r' int2str(sphere_radius)]
% details = details(details ~= ' ')
roitosave = label(sphere_roi, details)
% save ROI to MarsBaR ROI file, in current directory
detailsmat = [details, '_roi.mat']  % this naming subfix is in order to can be viewed in MARSBAR gui
saveroi(roitosave, fullfile(root_dir,detailsmat ));
% also Save as image that can be viewed in MRIcroN
detailsimg = [details, '_roi.nii']
save_as_image(roitosave, fullfile(root_dir,detailsimg));

   %% use REST functions to convert the .nii files into img pairs
        [Data, Head] = FG_rest_ReadNiftiImage(fullfile(root_dir,detailsimg));
        Head.n=[1 1];
        PO = fullfile(root_dir,detailsimg);
        [Path, fileN, extn] = fileparts(PO);
        POout=[Path,filesep,fileN,'.img'];
        FG_rest_WriteNiftiImage(Data,Head,POout);
        
        fname = PO;
        eval(['delete ''' fname '''']) % delete all the tempporal .nii files if you want


end
fprintf('\n -----------We are done~~~\n')

%*********************************************
%if instead you need to make a bunch of different types of ROIs, comment
%out the entire for end loop above, and use this part of the script instead.
%%See maroi_box and maroi_img (in marsbar directory) for other types of ROIs


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%THIS SECTION NAMES ROIS AS THEIR COORDINATES AND RADII

% %Make sphere ROI
% area = 'SMA_10sph'
% sphere_centre = [-8 2 72];
% sphere_radius = 10
% sphere_roi = maroi_sphere(struct('centre', sphere_centre, 'radius', sphere_radius));
% % Give it a name
% details = [area int2str(sphere_centre) int2str(sphere_radius)]
% details = details(details ~= ' ')
% roitosave = label(sphere_roi, details)
% % save ROI to MarsBaR ROI file, in current directory, just to show how
% detailsmat = [details, '_roi.mat']
% saveroi(roitosave, fullfile(roi_dir,detailsmat ));
% % Save as image
% detailsimg = [details, '_roi.nii']
% save_as_image(roitosave, detailsimg);
% 
% 
% %Make sphere ROI
% area = 'LIFG_5sph'
% sphere_centre = [-52 13 14];
% sphere_radius = 5
% sphere_roi = maroi_sphere(struct('centre', sphere_centre, 'radius', sphere_radius));
% % Give it a name
% details = [area int2str(sphere_centre) int2str(sphere_radius)]
% details = details(details ~= ' ')
% roitosave = label(sphere_roi, details)
% % save ROI to MarsBaR ROI file, in current directory, just to show how
% detailsmat = [details, '_roi.mat']
% saveroi(roitosave, fullfile(roi_dir,detailsmat ));
% % Save as image
% detailsimg = [details, '_roi.nii']
% save_as_image(roitosave, detailsimg);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %THIS SECTION NAMES ROIS BY HAND, AND STORES THEM SO THEY CAN BE COMBINED
% 
% %Make sphere ROI
% sphere_centre = [-6 -4 66];
% sphere_radius = 4
% sphere_roi = maroi_sphere(struct('centre', sphere_centre, 'radius', sphere_radius));;
% % Give it a name
% roitosave = label(sphere_roi, 'LSMAsphere_4mm_highres_-6_-4_66')
% LSMAroi = roitosave
% % save ROI to MarsBaR ROI file, in current directory, just to show how
% saveroi(roitosave, fullfile(roi_dir, 'LSMAsphere_4mm_highres_-6_-4_66_roi.mat'));
% 
% % Save as image
% save_as_image(roitosave, 'LSMAsphere_4mm_highres_-6_-4_66_roi.nii');
% 
% %Make sphere ROI
% sphere_centre = [6 0 66];
% sphere_radius = 4
% sphere_roi = maroi_sphere(struct('centre', sphere_centre, 'radius', sphere_radius));;
% % Give it a name
% roitosave = label(sphere_roi, 'RSMAsphere_4mm_highres_6_0_66')
% RSMAroi = roitosave
% % save ROI to MarsBaR ROI file, in current directory, just to show how
% saveroi(roitosave, fullfile(roi_dir, 'RSMAsphere_4mm_highres_6_0_66_roi.mat'));
% 
% % Save as image
% save_as_image(roitosave, 'RSMAsphere_4mm_highres_6_0_66_roi.nii');

%THIS COMBINES ALL NAMED ROIS SPECIFIED ABOVE INTO 1 BIG ROI

% All_rois = RSMAroi + LSMAroi;
% % Give it a name
% All_rois = label(All_rois, 'RSMA+LSMA_4mmhighres_roi');
% 
% % save ROI to MarsBaR ROI file, in current directory
% saveroi(All_rois, fullfile(roi_dir, 'RLSMA_4mmhighres_roi.mat'));
% 
% % Save as image
% save_as_image(All_rois, RLSMA_4mmhighres_roi.nii');
