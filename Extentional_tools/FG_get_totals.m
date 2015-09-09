function varargout = FG_get_totals(files, thr, msk)
clc
% check spm version:
if exist('spm_select','file') % should be true for spm5
    spm5 = 1;
    select = @(msg) spm_select(inf, 'image', msg);
elseif exist('spm_get','file') % should be true for spm2
    spm5 = 0;
    select = @(msg) spm_get(inf, 'img', msg);    %% cliff!!  Use the function handle!!
else
    error('Failed to locate spm_get or spm_select; please add SPM to Matlab path')
end

if nargin==0
    files = select('choose images that you want to get its total volume (ml)');
    if isempty(files), return; end

    prompt = {'Enter a absolute value to threshlod the image (only select the voxels than is bigger than this value; Default is to include all voxels)'};
    dlg_title = 'Absolute value threshold...';
    num_lines = 1;
    def = {'-inf'};
    thr = inputdlg(prompt,dlg_title,num_lines,def);
    thr=eval(thr{1});

    msk = select('choose common mask for all the selected images, or just skip this step~');

    if isempty(msk)
        [t, files,VS_N] = get_totals(files, thr);
    elseif ~isempty(msk)
        [t, files,VS_N] = get_totals(files, thr, msk);
    end
    fprintf('\n---voxel volumes:\n')
    t
    fprintf('\n---files:\n')
    files
    fprintf('\n---voxel numbers:\n')
    VS_N
    
elseif nargin==3
    [t, files,VS_N] = get_totals(files, thr, msk);
    fprintf('\n---voxel volumes:\n')
    t
    fprintf('\n---files:\n')
    files
    fprintf('\n---voxel numbers:\n')
    VS_N
elseif nargin==2
    [t, files,VS_N] = get_totals(files, thr);
    fprintf('\n---voxel volumes:\n')
    t
    fprintf('\n---files:\n')
    files
    fprintf('\n---voxel numbers:\n')
    VS_N
end
if nargout~=0
    varargout={t; files;VS_N};
end
%% sub function
function [t, files,VS_N] = get_totals(files, thr, msk)
%get_totals - Returns image totals (sum over all voxels), in ml
%  t = get_totals
%  [t files] = get_totals(files, thr, msk)
% GUI file-selection is used if files not specified as argument (or empty).
%
% If thr is given, this will be treated as an absolute threshold
% (i.e. values below this will be zeroed, hence the total will better match
% the GM analysed in the voxelwise stats, with the same threshold masking).
%
% Similarly, if msk is specified this image will be used as an explicit
% mask (i.e. only non-zero mask voxels will be included).
% GUI file-selection is used if msk is given as empty string ('').
% [Currently, masking assumes that msk matches the voxel dimensions of each
% image, and that therefore, all images have the same dimensions.]

% check spm version:
if exist('spm_select','file') % should be true for spm5
    spm5 = 1;
    select = @(msg) spm_select(inf, 'image', msg);
elseif exist('spm_get','file') % should be true for spm2
    spm5 = 0;
    select = @(msg) spm_get(inf, 'img', msg);
else
    error('Failed to locate spm_get or spm_select; please add SPM to Matlab path')
end

if ( ~exist('files', 'var') || isempty(files) )
    files = select('choose images that you want to get its total volume (ml)');
end
if ( ~exist('thr', 'var') || isempty(thr) )
    thr = -inf; % default to include everything (except NaNs)
end
if ~exist('msk', 'var')
    msk = 1; % default to include everything
end
if isempty(msk)
    msk = select('Choose a common mask image that has same dimention as the selected images');
end
if ischar(msk)
    msk = spm_vol(msk);
end
if isstruct(msk)
    msk = spm_read_vols(msk);
end
msk = msk ~= 0;

vols = spm_vol(files);
N = length(vols);

t = zeros(N,1);
VS_N=t;
for n = 1:N
    vsz = abs(det(vols(n).mat)); % det 是求一个image的行列式，在空间几何上他就是图像的 “面积/体积”； 这里求的的是一个voxel的体积， vsz/1000的单位就是（ml）
   % Mat=spm_vol(img); Vox_size = double(Mat.private.hdr.pixdim(2:4));   % Voxel_size = abs(VOX); voxelsize
    img = spm_read_vols(vols(n)); 
    img = img .* msk;
    VS_N(n)=sum(img(img > thr)); % get the number of voxels
    t(n) = sum(img(img > thr)) * vsz / 1000; % vsz in mm^3 (= 0.001 ml)
end
