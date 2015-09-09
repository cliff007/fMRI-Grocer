function mean_corr_3D=FG_correlation_voxel_AllVoxels(Vol_4D,mask)
if nargin==0
    cd ('D:\FunImgRWSDFC\01_HZQ');
    imgs=FG_list_all_files('D:\FunImgRWSDFC\01_HZQ','*','*img');
    Vol_4D=FG_read_vols(imgs);   
end



% get the volume size of input
[nDim1, nDim2, nDim3, nDim4]=size(Vol_4D);
%  Apply Mask
if exist('mask','var')==1
    mask =logical(mask);%ensure the mask only contain only 0 and 1
else
    mask=ones(nDim1, nDim2, nDim3);
end

mask =	repmat(mask, [1, 1, 1, nDim4]);
Vol_4D(~mask)=0;
% clear mask

    
fprintf('\nCaculating mean correlation coefficient of each voxel and all voxel...')



fprintf('\n--- ICC calculation starts! Start timing.................')
fprintf('\n--- It may take quite a long time, be patient...')
fprintf('\n--- Processing bar: 1%%  ')
tic

mean_corr_voxels=zeros(1,nDim1*nDim2*nDim3);
Vol_tem=reshape(Vol_4D,nDim1*nDim2*nDim3,nDim4)';

NVoxels=500;
NParts=ceil(nDim1*nDim2*nDim3/NVoxels);

Sbar_start=0.01; % initial processing bar value

for i=1:NParts
    
    if i<NParts
        ROI_TCs=Vol_tem(:,(i-1)*NVoxels+1:i*NVoxels);
        corr_voxels=FG_correlation_ROIs_AllVoxels_fast(ROI_TCs,Vol_4D);
%         corr_voxels=corr_voxels(find(corr_voxels)); % remove zeros
        mean_corr_voxels(1,(i-1)*NVoxels+1:i*NVoxels)=mean(reshape(corr_voxels,nDim1*nDim2*nDim3,size(ROI_TCs,2)),1); 
        clear corr_voxels
    elseif i==NParts
        ROI_TCs=Vol_tem(:,(i-1)*NVoxels+1:nDim1*nDim2*nDim3);
        corr_voxels=FG_correlation_ROIs_AllVoxels_fast(ROI_TCs,Vol_4D);
%         corr_voxels=corr_voxels(find(corr_voxels)); % remove zeros
        mean_corr_voxels(1,(i-1)*NVoxels+1:nDim1*nDim2*nDim3)=mean(reshape(corr_voxels,nDim1*nDim2*nDim3,size(ROI_TCs,2)),1); 
        clear corr_voxels
    end
    
    if (i*NVoxels/nDim1*nDim2*nDim3)>Sbar_start
        Sbar1=100*i/NParts;
        Sbar_start=Sbar_start+0.1;
        fprintf(' %s%%',num2str(Sbar1(1)))
    end
    
end

clear Vol_tem
mean_corr_3D=reshape(mean_corr_voxels',nDim1, nDim2, nDim3);
clear mean_corr_voxels

total_t=toc;
fprintf('\n--- It takes totally %s mins to finish!!!\n',num2str(total_t/60))


fprintf('\ndone...')


%%% subfunction %%%%
function mat=FG_replace_Nan_as_zero(mat)
[dim1,dim2]=size(mat);
tem=find(isnan(mat));
mat(tem)=0;





