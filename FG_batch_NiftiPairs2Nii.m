function FG_batch_NiftiPairs2Nii(roi_name,del_h)
    if nargin==0
        % select the nii ROIs/imgs(.nii)
          if strcmp(spm('ver',[],1),'SPM5')||strcmp(spm('ver',[],1),'SPM8')
               roi_name = spm_select(Inf,'any','Select nii ROIs(*.img):', [],pwd,'.*img$');
          else  
               roi_name = spm_get(Inf,'any','Select nii ROIs(*.img$):'); 
          end
          if isempty(roi_name)
              return
          end

          del_h=questdlg('Do you want to delete the original files after format transform?','Delete or not....','Yes','No','No') ;
    end
    
  pause(0.5)  
  num=size(roi_name,1);

    for i=1:num
        head = spm_vol(roi_name(i,:));
        dat=spm_read_vols(head);
        [pathes, names,new_names,head.fname]=FG_separate_files_into_name_and_path(deblank(roi_name(i,:)),'','prefix','.nii');
%         PO = roi_name(i,:);
%         [Path, fileN, extn] = fileparts(PO);
%         POout=[Path,filesep,fileN,'.img'];
        spm_write_vol(head,dat);
        if strcmpi(del_h,'Yes')
            delete (deblank(roi_name(i,:)))
            delete (FG_corresponding_name_of_hdr_img_pair(deblank(roi_name(i,:))))
        end
    end
fprintf('\n-------------hdr/img pair to nii is done~~~~~~~~~~\n\n')