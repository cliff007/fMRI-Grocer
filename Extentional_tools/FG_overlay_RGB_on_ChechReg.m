function FG_overlay_RGB_on_ChechReg(varargin)
% e.g. FG_overlay_RGB_on_ChechReg(BGimg)
% this script try to overlay three(only three) ROI imgs on a background
% image with R,G,B three colors

if nargin==0
    a=which('fmri_grocer');
    [pth,name,ext,even]=FG_fileparts(a);
    BGimg=spm_select(1,'any','Please select the background image(e.g. colin.img)...',[],fullfile(pth, 'Templates'),'.*img$|.*nii$');
    if isempty(BGimg), return; end
elseif nargin==2
    BGimg=varargin{1};
end


FG_enhanced_spm_check_registration(BGimg)

out_names=FG_spm_ov_rgb('context_init', ...
                1) ; % target position

for i=1:size(out_names,1)
    [pth,name,ext,even]=FG_fileparts(deblank(out_names(i,:)));
    delete ([name '*.*'])
end
                
