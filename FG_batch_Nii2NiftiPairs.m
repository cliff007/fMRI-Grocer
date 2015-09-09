function FG_batch_Nii2NiftiPairs(roi_name,del_h)
    if nargin==0
        % select the nii ROIs/imgs(.nii)
          if strcmp(spm('ver',[],1),'SPM5')||strcmp(spm('ver',[],1),'SPM8')
               roi_name = spm_select(Inf,'any','Select nii ROIs(*.nii):', [],pwd,'.*nii$');
          else  
               roi_name = spm_get(Inf,'any','Select nii ROIs(*.nii$):'); 
          end
          if isempty(roi_name)
              return
          end

          del_h=questdlg('Do you want to delete the original files after format transform?','Delete or not....','Yes','No','No') ;
    end
    
  pause(0.5)
  num=size(roi_name,1);
% addpath(fullfile(FG_rest_misc('WhereIsREST'), 'rest_spm5_files'));
    for i=1:num
        head = spm_vol(roi_name(i,:));
        dat=spm_read_vols(head);
        [pathes, names,new_names,head.fname]=FG_separate_files_into_name_and_path(deblank(roi_name(i,:)),'','prefix','.img');
%         PO = roi_name(i,:);
%         [Path, fileN, extn] = fileparts(PO);
%         POout=[Path,filesep,fileN,'.img'];
        spm_write_vol(head,dat);
        if strcmpi(del_h,'Yes')
            delete (deblank(roi_name(i,:)))
        end
    end
fprintf('\n-------------.nii to hdr/img pair is done~~~~~~~~~~\n\n')