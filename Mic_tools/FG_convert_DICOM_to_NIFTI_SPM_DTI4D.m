function FG_convert_DICOM_to_NIFTI_SPM_DTI4D(dicoms,out_format,DelorNo)
% use SPM function, the outoput names can't be flexibly defined
    if nargin==0
        dicoms = spm_select(inf,'any','Select the Dicom images', [],pwd,'.*');
        if isempty(dicoms),return, end
%         OutputDir = spm_select(1,'dir','Select a dir for the outputs', [],pwd);
%         if isempty(OutputDir),return, end
%         out_format = questdlg('Select a output file format...','Hi...','nii','img','nii') ;
        out_format='nii';
        DelorNo = questdlg('Do you want to delete original Dicom files?','Hi...','Del','No','No') ;
    end
    if isempty(dicoms),return, end
%     if isempty(OutputDir),return, end
    pause(0.5)
    hdrs=spm_dicom_headers(dicoms);
    out = FG_spm_dicom_convert_RevisedRenameMethod (hdrs,'all','flat',out_format);
%     out = FG_spm_dicom_convert_RevisedRenameMethod(hdrs,'all','series',out_format); % move images into separate scanning series folders
    out.files;
    DTI_4D=FG_cat_to_4D(out.files, 'f_4D', pwd);
    if strcmpi(DelorNo,'Del')
        for i=1:size(dicoms,1)
            delete(deblank(dicoms(i,:)));
        end
    end
    
    for i=1:size(out.files,1)
        delete(deblank(out.files{i}));
    end
    fprintf('\n\n======== Dicom ---> Nifti is done...\n');

    
    
%% sub function:  FG_cat_to_4D
    
function fileprefix=FG_cat_to_4D(filelist, fileprefix, outroot)

   if ~exist('fileprefix','var')
      fileprefix = 'multi_scan';
   else
      [tmp fileprefix] = fileparts(fileprefix);
      clear tmp
   end

   if ~exist('outroot','var'), outroot = pwd; end


   fileprefix=[fileprefix,'_',num2str(size(filelist,1))] ; % redefine the file name
   
   nii = FG_load_untouch_nii(filelist{1});
   nii.hdr.dime.dim(5) = length(filelist);

   if nii.hdr.dime.dim(1) < 4
      nii.hdr.dime.dim(1) = 4;
   end

   hdr = nii.hdr;
   filetype = nii.filetype;

   if isfield(nii,'ext') & ~isempty(nii.ext)
      ext = nii.ext;
      [ext, esize_total] = verify_nii_ext(ext);
   else
      ext = [];
   end

   switch double(hdr.dime.datatype),
   case   1,
      hdr.dime.bitpix = int16(1 ); precision = 'ubit1';
   case   2,
      hdr.dime.bitpix = int16(8 ); precision = 'uint8';
   case   4,
      hdr.dime.bitpix = int16(16); precision = 'int16';
   case   8,
      hdr.dime.bitpix = int16(32); precision = 'int32';
   case  16,
      hdr.dime.bitpix = int16(32); precision = 'float32';
   case  32,
      hdr.dime.bitpix = int16(64); precision = 'float32';
   case  64,
      hdr.dime.bitpix = int16(64); precision = 'float64';
   case 128,
      hdr.dime.bitpix = int16(24); precision = 'uint8';
   case 256 
      hdr.dime.bitpix = int16(8 ); precision = 'int8';
   case 512 
      hdr.dime.bitpix = int16(16); precision = 'uint16';
   case 768 
      hdr.dime.bitpix = int16(32); precision = 'uint32';
   case 1024
      hdr.dime.bitpix = int16(64); precision = 'int64';
   case 1280
      hdr.dime.bitpix = int16(64); precision = 'uint64';
   case 1792,
      hdr.dime.bitpix = int16(128); precision = 'float64';
   otherwise
      error('This datatype is not supported');
   end

   if filetype == 2
      fid = fopen(sprintf('%s.nii',fileprefix),'w');
      
      if fid < 0,
         msg = sprintf('Cannot open file %s.nii.',fileprefix);
         error(msg);
      end
      
      hdr.dime.vox_offset = 352;

      if ~isempty(ext)
         hdr.dime.vox_offset = hdr.dime.vox_offset + esize_total;
      end

      hdr.hist.magic = 'n+1';
      FG_save_untouch_nii_hdr(hdr, fid);

      if ~isempty(ext)
         FG_save_nii_ext(ext, fid);
      end
   elseif filetype == 1
      fid = fopen(sprintf('%s.hdr',fileprefix),'w');
      
      if fid < 0,
         msg = sprintf('Cannot open file %s.hdr.',fileprefix);
         error(msg);
      end
      
      hdr.dime.vox_offset = 0;
      hdr.hist.magic = 'ni1';
      FG_save_untouch_nii_hdr(hdr, fid);

      if ~isempty(ext)
         FG_save_nii_ext(ext, fid);
      end
      
      fclose(fid);
      fid = fopen(sprintf('%s.img',fileprefix),'w');
   else
      fid = fopen(sprintf('%s.hdr',fileprefix),'w');
      
      if fid < 0,
         msg = sprintf('Cannot open file %s.hdr.',fileprefix);
         error(msg);
      end
      
      FG_save_untouch0_nii_hdr(hdr, fid);
      
      fclose(fid);
      fid = fopen(sprintf('%s.img',fileprefix),'w');   % write the *.img file
   end

   if filetype == 2 & isempty(ext)
      skip_bytes = double(hdr.dime.vox_offset) - 348;
   else
      skip_bytes = 0;
   end

   if skip_bytes
      fwrite(fid, zeros(1,skip_bytes), 'uint8');
   end

   glmax = -inf;
   glmin = inf;

   for i = 1:length(filelist)
      nii = FG_load_untouch_nii(filelist{i});

      if double(hdr.dime.datatype) == 128

         %  RGB planes are expected to be in the 4th dimension of nii.img
         %
         if(size(nii.img,4)~=3)
            error(['The NII structure does not appear to have 3 RGB color planes in the 4th dimension']);
         end

         nii.img = permute(nii.img, [4 1 2 3 5 6 7 8]);
      end

      %  For complex float32 or complex float64, voxel values
      %  include [real, imag]
      %
      if hdr.dime.datatype == 32 | hdr.dime.datatype == 1792
         real_img = real(nii.img(:))';
         nii.img = imag(nii.img(:))';
         nii.img = [real_img; nii.img];
      end

      if nii.hdr.dime.glmax > glmax
         glmax = nii.hdr.dime.glmax;
      end

      if nii.hdr.dime.glmin < glmin
         glmin = nii.hdr.dime.glmin;
      end

      fwrite(fid, nii.img, precision);
   end

   hdr.dime.glmax = round(glmax);
   hdr.dime.glmin = round(glmin);

   if filetype == 2
      fseek(fid, 140, 'bof');
      fwrite(fid, hdr.dime.glmax, 'int32');
      fwrite(fid, hdr.dime.glmin, 'int32');
   elseif filetype == 1
      fid2 = fopen(sprintf('%s.hdr',fileprefix),'w');   % write the *.hdr file

      if fid2 < 0,
         msg = sprintf('Cannot open file %s.hdr.',fileprefix);
         error(msg);
      end

      FG_save_untouch_nii_hdr(hdr, fid2);

      if ~isempty(ext)
         FG_save_nii_ext(ext, fid2);
      end

      fclose(fid2);
   else
      fid2 = fopen(sprintf('%s.hdr',fileprefix),'w');

      if fid2 < 0,
         msg = sprintf('Cannot open file %s.hdr.',fileprefix);
         error(msg);
      end

      FG_save_untouch0_nii_hdr(hdr, fid2);

      fclose(fid2);
   end

   fclose(fid);

   return;					% collapse_nii_scan
