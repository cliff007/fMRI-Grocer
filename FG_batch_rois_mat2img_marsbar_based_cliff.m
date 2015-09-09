function FG_batch_rois_mat2img_marsbar_based_cliff
% http://comments.gmane.org/gmane.comp.graphics.spm.marsbar/1216

     % if you find this script doesn't work correctly when you run this directly
     % please run this transformation in marsbar GUI once first
     % then you can run this script successfully. 
     % It is something wrong about .ext. I don't know why. 

% Please note the difference between "ROI native space" and "Based space for ROI"
 
% MarsBaR version check
if isempty(which('marsbar'))
  error('Need MarsBaR on the path');
end
v = str2num(marsbar('ver'));
if v < 0.35
  error('Batch script only works for MarsBaR >= 0.35');
end

% the following two lines are critical. Otherwise, the marsbar won't run correctly
marsbar('on');  % needed to set paths etc
% Set up the SPM defaults, just in case
spm('defaults', 'fmri');


addpath(fullfile(FG_rest_misc('WhereIsREST'), 'rest_spm5_files')); % need to utilize REST

[Finter,Fgraph,CmdLine] = spm('FnUIsetup','Write ROI to image');

% select the ROIs(.mat)
  if strcmp(spm('ver',[],1),'SPM5')|strcmp(spm('ver',[],1),'SPM8')
       roi_name = spm_select(Inf,'.mat','Select marsbar_ROIs(*.mat):', [],pwd,'.*mat');
  else  
       roi_name = spm_get(Inf,'*.mat','Select marsbar_ROIs(*.mat):'); 
  end
  
    if isempty(roi_name)
        return
    end
  num=size(roi_name,1);
  
for j=1:num 
    [pn fn ext] = fileparts(roi_name(j,:));
    roi = maroi('load', roi_name(j,:));

    % select the space  

    spopts = {'spacebase','image'};
    splabs =  {'Base space for ROIs','From image'};
    if has_space(roi)
      spopts = {spopts{:} 'native'};
      splabs = {splabs{:} 'ROI native space'};
    end

    if j==1% decide the space at the first time, then use this selection repeatly
        spo = spm_input('Space for ROI image', '+1', 'm',splabs,...
                spopts, 1);
        switch char(spo)
         case 'spacebase'
           sp = maroi('classdata', 'spacebase');
         case 'image'
          img = spm_get([0 1], mars_veropts('get_img_ext'), 'Image defining space');
          if isempty(img),return,end
          sp = mars_space(img);
         case 'native'
          sp = [];
        end
    else
        sp=sp;
    end

    % remove ROI file ending
    %gend = maroi('classdata', 'fileend');
    %lg = length(gend);
    %f2 = [fn ext];
    %if length(f2)>=lg & strcmp(gend, [f2(end - lg +1 : end)])
    %  f2 = f2(1:end-lg);
    %else
      f2 = fn;
    %end

    if j==1 % decide the path to save .nii rois at the first time
        fname = mars_utils('get_img_name', f2);
    else
        [pn1 fn1 ext1] = fileparts(fname);
        fname = [pn1,filesep,f2,ext1]; %revise pathname to add \ or /
    end

    if isempty(fname), return, end
    save_as_image(roi, fname, sp);
    fprintf('Saved ROI as %s\n',fname);
    
        %% use REST functions to convert the .nii files into img pairs
        [Data, Head] = FG_rest_ReadNiftiImage(fname);
        Head.n=[1 1];
        PO = fname;
        [Path, fileN, extn] = fileparts(PO);
       % POout=[Path,filesep,fileN,'_',Index,'.img'];
        POout=[Path,filesep,fileN,'.img'];
        FG_rest_WriteNiftiImage(Data,Head,POout);
        
        
        eval(['delete ''' fname ''''])  % delete all the tempporal .nii files if you want

end
    
fprintf('convertion done~~~\n\n');






