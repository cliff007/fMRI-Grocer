%  Return time frame of a NIFTI dataset. Support both *.nii and 
%  *.hdr/*.img file extension. If file extension is not provided,
%  *.hdr/*.img will be used as default. 
%
%  It is a lightweighted "load_nii_hdr", and is equivalent to
%  hdr.dime.dim(5)
%  
%  Usage: [ total_scan ] = get_nii_frame(filename)
%
%  filename - NIFTI file name.
%
%  Returned values:
%
%  total_scan - total number of image scans for the time frame
%
%  NIFTI data format can be found on: http://nifti.nimh.nih.gov
%
%  - Jimmy Shen (jimmy@rotman-baycrest.on.ca)
%
function [total_scan,dim,xyz] = FG_get_nii_frame(filename)
    if nargin==0
       filename=spm_select(1,'.*nii|.*img','Please select a 3D/4D Nifti image',[],pwd) ;
    end

%    if ~exist('filename','var'),
%       error('Usage: [ hdr, filename, machine ] = FG_get_nii_frame(file_input)');
%    end
% 
   if ~exist('machine','var'), machine = 'ieee-le'; end  %% 'ieee-le':IEEE floating point with little-endian byte ordering. one of the Precision Support of "fopen"

   new_ext = 0;

   if findstr('.nii',filename)
      new_ext = 1;
      filename = strrep(filename,'.nii','');  % Neat!!!  STRREP:  Replace string with another.
   end

   if findstr('.hdr',filename)
      filename = strrep(filename,'.hdr','');
   end

   if findstr('.img',filename)
      filename = strrep(filename,'.img','');
   end

   if new_ext  % for nii
      fn = sprintf('%s.nii',filename);

      if ~exist(fn)
         msg = sprintf('Cannot find file "%s.nii".', filename);
         error(msg);
      end
   else   % for img/hdr
      fn = sprintf('%s.hdr',filename);

      if ~exist(fn)
         msg = sprintf('Cannot find file "%s.hdr".', filename);
         error(msg);
      end
   end

   % Be careful: the img matrix read by a=fread(fopen('*.nii')), and
   %             the img matrix read by b=spm_read_vols(spm_vol('*.nii')),
   %             a is double size of b, because a is composed is such a
   %             rule that most of the elements (!!!!Not all!!!!) of b was followed by a extra element '0'
   %             that means a(1:2:end) == b
   
   fid = fopen(fn,'r',machine);   
    
   if fid < 0,
      msg = sprintf('Cannot open file %s.',fn);
      error(msg);
   else
      hdr = read_header(fid);
      fclose(fid);
   end
   
   if hdr.sizeof_hdr ~= 348
      % first try reading the opposite endian to 'machine'
      switch machine,
      case 'ieee-le', machine = 'ieee-be';
      case 'ieee-be', machine = 'ieee-le';
      end
        
      fid = fopen(fn,'r',machine);
        
      if fid < 0,
         msg = sprintf('Cannot open file %s.',fn);
         error(msg);
      else
         hdr = read_header(fid);
         fclose(fid);
      end
   end

   if hdr.sizeof_hdr ~= 348
      % Now throw an error
      msg = sprintf('File "%s" is corrupted.',fn);
      error(msg);
   end

   total_scan = hdr.dim(5);
   dim=hdr.dim(1);
   xyz=[hdr.dim(2),hdr.dim(3),hdr.dim(4)];
   
 %  fprintf('\n----\n''%s'' is a %dD, x= %d y= %d z= %d image, totally %d volume(s) ...\n',fn,dim,hdr.dim(2),hdr.dim(3),hdr.dim(4),total_scan)

   return;					% get_nii_frame


%---------------------------------------------------------------------
function [ dsr ] = read_header(fid)

%     dat=fread(fid,'int32')';
%     dat1=dat([1 40:50])';
    
%     dat2=fread(fid,'int16');
%     dat3=dat2(30:50)';
    
    fseek(fid,0,'bof');
    dsr.sizeof_hdr    = fread(fid,1,'int32')' ; % should be 348!
    
    fseek(fid,40,'bof');
    dsr.dim           = fread(fid,8,'int16')';

    return;					% read_header

