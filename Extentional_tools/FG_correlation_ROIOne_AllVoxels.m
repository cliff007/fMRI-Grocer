function Vol_3D_corr=FG_correlation_ROIOne_AllVoxels(ROI_TC,Vol_4D)
if nargin==0
    cd ('D:\FunImgRWSDFC\01_HZQ');
    imgs=FG_list_all_files('D:\FunImgRWSDFC\01_HZQ','*','*img');
    Vol_4D=FG_read_vols(imgs);
    ROI_TC=Vol_4D(25,30,20,:);
    ROI_TC=squeeze(ROI_TC);
    
end


%Make sure the 1st dim of Covariates is nDim4 long
[nDim1, nDim2, nDim3, nDim4]=size(Vol_4D);
if size(ROI_TC,1)~=nDim4, error('The length of timecouse of ROI-ROI don''t match the volume.'); end


fprintf('\nCaculating correlation coefficient of ROI and each voxel...')
% separate and save the 4D dataset along the 1st dimension to reduce the load of memory
for x=1:nDim1    
    oneAxialSlice =squeeze(Vol_4D(x, :, :, :));
    oneAxialSlice=reshape(oneAxialSlice,nDim2*nDim3,nDim4)';
    oneAxialSlice_corr = corrcoef([ROI_TC oneAxialSlice]);
    oneAxialSlice_corr=oneAxialSlice_corr(1,2:end);    
    Vol_3D_corr(x, :, :) =reshape(oneAxialSlice_corr,nDim2,nDim3);
end;
fprintf('\ndone...')






