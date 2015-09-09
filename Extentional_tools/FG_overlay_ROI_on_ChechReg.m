function FG_overlay_ROI_on_ChechReg(varargin)
% e.g. FG_overlay_ROI_on_ChechReg(imgs,BGimg)

%     global st
%     existed_vols=st.vols;
%     j=0;
%     for i=1:24
%         if ~isempty(existed_vols{i})
%             j=j+1;
%         end
%     end
%     uiwait(msgbox(['Now there are ' num2str(j) ' images in the check viewer window...'],'Instruction...','modal'))
%     target_pos=inputdlg('Please enter the target
%     positon','hi...',1,{num2str([1:size(imgs,1)])});
%     target_pos=str2num(target_pos{1});

if nargin==0
    imgs=spm_select([1,15],'any','Please select the overlay images...',[],pwd,'.*img$|.*nii$');
    if isempty(imgs), return; end

    a=which('fmri_grocer');
    [pth,name,ext,even]=FG_fileparts(a);
    BGimg=spm_select(1,'any','Please select a background image(e.g. colin.img)...',[],fullfile(pth, 'Templates'),'.*img$|.*nii$');
    if isempty(BGimg), return; end
elseif nargin==2
    imgs=varargin{1};
    BGimg=varargin{2};
end

BGs=repmat(BGimg,[size(imgs,1),1]);
FG_enhanced_spm_check_registration(BGs)

for i=1:size(imgs,1)
    FG_spm_ov_roi('init', ...
                i, ... % target position
                deblank(imgs(i,:)), ...
                1) % fixed value   %%          spm_orthviews('addcolouredblobs', volhandle, ...
                                                            %  st.vols{volhandle}.roi.xyz, ones(size(st.vols{volhandle}.roi.xyz,2),1), ... 
                                                            %  st.vols{volhandle}.roi.Vroi.mat,[1 3 1]); % use color that is more intense than standard rgb range
end