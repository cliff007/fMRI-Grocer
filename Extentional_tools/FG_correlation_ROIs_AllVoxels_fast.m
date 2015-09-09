function varargout=FG_correlation_ROIs_AllVoxels_fast(ROI_TCs,Vol_4D,mask)
if nargin==0
    cd ('D:\FunImgRWSDFC\01_HZQ');
    imgs=FG_list_all_files('D:\FunImgRWSDFC\01_HZQ','*','*img');
    Vol_4D=FG_read_vols(imgs);  
    ROI_TCs=Vol_4D(25,30,20,:);
    ROI_TCs=squeeze(ROI_TCs); 
%     Vol_4D=imgs;
end


% get the volume size of input
[nDim1, nDim2, nDim3, nDim4]=size(Vol_4D);

%  define Mask
if exist('mask','var')==1
    mask =logical(mask);%ensure the mask only contain only 0 and 1
else
    mask=ones(nDim1, nDim2, nDim3);
end

fprintf('\nCaculating correlation coefficient ROIs-AllVoxels...')
if size(ROI_TCs,2)==1
    [FCmaps,FC_vols]=FG_correlation_ROIOne_AllVoxels_fast(ROI_TCs,Vol_4D,mask);
elseif size(ROI_TCs,2)>1
    [FCmaps,FC_vols]=FG_correlation_ROIMulti_AllVoxels_fast(ROI_TCs,Vol_4D,mask);
end
fprintf('\....done...\n')

    if nargout~=0
        varargout={FCmaps,FC_vols};
    end   