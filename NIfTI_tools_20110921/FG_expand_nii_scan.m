%  Expand a multiple-scan NIFTI file into multiple single-scan NIFTI files
%
%  Usage: expand_nii_scan(multi_scan_filename, [img_idx], [path_to_save])
%
%  NIFTI data format can be found on: http://nifti.nimh.nih.gov
%
%  - Jimmy Shen (jimmy@rotman-baycrest.on.ca)
%
function FG_expand_nii_scan(filename, img_idx, newpath)

    if nargin==0
       filename=spm_select(1,'.*nii','Please select a 4D Nifti image',[],pwd) ;
    end

   if ~exist('newpath','var'), newpath = pwd; end
   if ~exist('img_idx','var'), img_idx = 1:FG_get_nii_frame(filename); end

   for i=img_idx
      nii_i = FG_load_untouch_nii(filename, i);

      fn = [nii_i.fileprefix '_' sprintf('%04d',i)];
      pnfn = deblank(fn); %  cliff, original:pnfn = fullfile(newpath, fn);

      FG_save_untouch_nii(nii_i, pnfn);
   end

   return;					% expand_nii_scan

