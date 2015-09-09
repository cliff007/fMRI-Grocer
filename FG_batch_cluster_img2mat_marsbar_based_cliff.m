% Re: batch export roi to image
% http://comments.gmane.org/gmane.comp.graphics.spm.marsbar/1216

     % if you find this script doesn't work correctly when you run this directly
     % please run this transformation in marsbar GUI once first
     % then you can run this script successfully. 
     % It is something wrong about .ext. I don't know why. 
     
function FG_batch_cluster_img2mat_marsbar_based_cliff()

% MarsBaR version check
if isempty(which('marsbar'))
  error('Need MarsBaR on the path');
end
v = str2num(marsbar('ver'));
if v < 0.35
  error('Batch script only works for MarsBaR >= 0.35');
end

% the following two lines are critical. Otherwise, the marsbar won't run correctly

% Set up the SPM defaults, just in case
spm_get_defaults; %% important
spm('defaults', 'fmri');
marsbar('on');  % needed to set paths etc
 
tstr='Import ROIs';
pstr ='Import ROIs from:';
optfields={{'img2rois','c'}, {'img2rois','i'}};
optlabs={'cluster image',''};% 'number labelled ROI image'};

%[tstr pstr optfields optlabs]

[Finter,Fgraph,CmdLine] = spm('FnUIsetup',tstr);
of_end = length(optfields)+1;
my_task = spm_input(pstr, '+1', 'm',...
	      {optlabs{:} 'Quit'},...
	      [1:of_end],of_end);
if my_task == of_end, return, end

roi_type = 'c'; % default is cluster image,in this script, we don't handle "number labelled ROI image"


% select the ROIs imgs
  if strcmp(spm('ver',[],1),'SPM5')|strcmp(spm('ver',[],1),'SPM8')
       roi_img = spm_select(Inf,'any','Select ROIs imgs:', [],pwd,'.*img$|.*nii$');
  else  
       roi_img = spm_get(Inf,'any','Select ROIs imgsm:'); 
  end
  num=size(roi_img,1);
  
  roipath = spm_get([-1 0], '', 'Directory to save ROIs')
  
for j=1:num 
    P=deblank(roi_img(j,:));
    mars_img2rois_revised(P,roipath,'',roi_type);  % modified "mars_img2rois" function
    
end
    
fprintf('convertion done~~~\n\n');



%% self modified sub function
function mars_img2rois_revised(P, roipath, rootn, flags)
        
        if nargin < 1
          P = '';
        end
        if nargin < 2
          roipath = '';
        end
        if nargin < 3
          rootn = '';
        end
        if nargin < 4
          flags = ' ';
        end

        % Process input arguments
        if any(flags == 'i')
          Pprompt = 'Image containing ROI ids';
        else
          Pprompt = 'Image containing clusters';
        end
        if isempty(P)
          P = spm_get(1, mars_veropts('get_img_ext', Pprompt));
        end
        if isempty(P)
          return
        end
        if ischar(P)
          P = spm_vol(P);
        end
        if isempty(roipath)
          roipath = spm_get([-1 0], '', 'Directory to save ROIs');
        end
        if isempty(roipath)
          return
        end
        if isempty(rootn)
          [pn rootn ext] = fileparts(P.fname);
          % rootn = spm_input('Prefix for ROI filenames', '+1', 's', rootn);
        end
        if isempty(rootn)
          return
        end

        if isempty(flags)
          flags = 'i';  % id image is default
        end

        % read img, get non-zero voxels
        img = spm_read_vols(P);
        img = img(:)';
        dim = P.dim(1:3);
        pts = find(img~=0);

        % e2xyz
        nz = pts-1;
        pl_sz = dim(1)*dim(2);
        Z = floor(nz / pl_sz);
        nz = nz - Z*pl_sz;
        Y = floor(nz / dim(1));
        X = nz - Y*dim(1);
        XYZ = [X; Y;Z] +1;

        % collect clusters
        vals = img(pts);

        % select cluster or id 
        if any(flags == 'i')
          cl_vals = vals;
        else
          cl_vals = spm_clusters(XYZ);
        end

        for c = unique(cl_vals)
          % points for this region/cluster
          t_cl_is = find(cl_vals == c);

          % corresponding XYZ
          cXYZ = XYZ(:, t_cl_is);

          if ~isempty(cXYZ)
            % location label for cluster images
            if any(flags == 'c')
              if any(flags == 'x') % maximum 
            [mx maxi] = max(vals(t_cl_is));
            mi = t_cl_is(maxi);
            % voxel coordinate of max
            vco = XYZ(:, mi);
              else % centre of mass
            vco = mean(cXYZ, 2);
              end

              % pt coordinates in mm
              pt_lab = P.mat * [vco; 1];
              pt_lab = pt_lab(1:3);

              % file name and labels
              d = sprintf('%s cluster at [%0.1f %0.1f %0.1f]', rootn, pt_lab);
              l = sprintf('%s_%0.0f_%0.0f_%0.0f', rootn, pt_lab);

            else % id image labels from voxel values
              % file name and labels
              d = sprintf('%s: id: %d', rootn, c);
              l = sprintf('%s_%d', rootn, c);
            end

            fname = maroi('filename', fullfile(roipath, l));
            o = maroi_pointlist(struct('XYZ',cXYZ,...
                           'mat',P.mat,...
                           'descrip',d,...
                           'label', l), ...
                    'vox');
            fprintf('\nSaving %s as %s...', d, fname);
            saveroi(o, fname);
          end
        end
        fprintf('\nDone...\n');