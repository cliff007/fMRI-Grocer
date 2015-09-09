%         %     I assume that you have:
%         %     1. a NIfTI/Analyze home-made statistic image, spm.{hdr,img},
%         %     2. a NIfTI/Analyze mask image, mask.{hdr,img} with 0/1 labels, with same
%         %     dimensions and orientations than the previous file,
%         %     1. a height threshold u,
%         %     2. a cluster extent threshold k.
%         %     Then to create a new image, tspm.{hdr,img}, thresholded with u and k and
%         %     using mask, you can do something along those lines:
% 
%         u = 4; k = 10;
%         stat_img = spm_select(1,'image','Select your SPM_T/F image');
%         mask_img = spm_select(1,'image','Select your mask image');
%         vt = spm_vol(stat_img);
%         vm = spm_vol(mask_img);
%         t  = spm_read_vols(vt);
%         m  = spm_read_vols(vm);
%         t(m==0 | t < u) = NaN;
%         [l, n] = spm_bwlabel(double(~isnan(t)),26);  %%%  spm_bwlabel   <====> bwlabel
%         j  = histc(l(:),[0:max(l(:))]+0.5);
%         j  = j(1:end-1)';
%         for i=find(j<k), l(l==i) = 0; end
%         t(~l) = NaN;
%         vt.fname = 'thresholded_spm.nii';
%         spm_write_vol(vt,t);
%         spm_check_registration(char({stat_img,mask_img,'thresholded_spm.nii'}));



% cliff~~~~~~~~~~
stat_img = spm_select(inf,'any','Select your SPM_T/F image(s)',[],pwd,'.*nii$|.*img$');
if isempty(stat_img)
    return
end

button = questdlg('Select a overlay option','Overlay...','Overlay in one window','Overlay in separate window','Overlay in one window') ;
if strcmp(button,'Overlay in separate window')
    for i=1:size(stat_img,1)
        FG_xjview(deblank(stat_img(i,:)))
    end
else
    tem=[];
    for i=1:size(stat_img,1)
        tem= [tem, '''', deblank(stat_img(i,:)), '''', ', '];
    end
    tem=tem(1:end-2);
    eval(['FG_xjview(' tem ')'])
end