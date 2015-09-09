function FG_display_img_SPM(img)
if ~exist(img,'file')
    fprintf('\n--- Image is not existed.\n')
    return
else
    spm_image('init',img)
%     spm_image('display',img)
end