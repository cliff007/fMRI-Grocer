function [voxelsize,voxelvolume]=FG_get_voxelsize(imgs)
if nargin==0
    imgs=spm_select(inf,'image','Select images to read...');
    if isempty(imgs), return,end
end
    Vmats=spm_vol(imgs);
try
    spm_check_orientations(Vmats);
catch me
    errors=me.message;
    if strcmpi(errors,'The orientations etc must be identical for this procedure.')
        fprintf('\n---%s...',me.message)
        fprintf('\n---now we try to reset the origin of the images...\n')
        FG_reset_origin_selectedImgs(imgs);
        [Vs,Vmats]=FG_read_vols(imgs);
    elseif strcmpi(errors,'The dimensions must be identical for this procedure.')
        fprintf('\n--The dimensions must be identical for this procedure.\n')
        return
    else
        fprintf('\n\n--%s\n', errors)
        fprintf('--Something wrong with your input image, check it out first!\n')
        
    end
end

voxelsize=[];voxelvolume=[];
for i=1:size(Vmats,1)    
    voxelsize = [voxelsize ;double(Vmats(i).private.hdr.pixdim(2:4))];
    voxelvolume = [voxelvolume;abs(det(Vmats(i).mat))]; % should be same as voxelsize(1)*voxelsize(2)*voxelsize(3)
end

 fprintf('\n')