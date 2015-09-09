function varargout = FG_correlation_ROIOne_AllVoxels_fast(ROI_TC,Vol_4D,mask)
% Functional connectivity: cliff 2015
% ROI_TCs: should be a column vector to represents a timecourse of a ROI.
    %% In this script calculate the voxelwise correlation coefficient by manipulating the maxtix 
    %% with the textbook definition of r (rather than use "corrcoef") to faster the calculation
    %% r(x,y)=(X-Xmean)(Y-Ymean)/((n-1)*XSTD*YSTD)
    %% r(x,y)=zscore(x)*zscore(y)/(n-1),

if nargin==0
    cd ('D:\FunImgRWSDFC\01_HZQ');
    imgs=FG_list_all_files('D:\FunImgRWSDFC\01_HZQ','*','*img');
    Vol_4D=FG_read_vols(imgs);
    ROI_TC=Vol_4D(25,30,20,:);
    ROI_TC=squeeze(ROI_TC);    
    Vol_4D=imgs;
end

% inputs can be either the fullname image file or the volume matrix
if ischar(Vol_4D)   
   [Vol_4D,Header]=FG_read_vols(Vol_4D);
   Header=Header(1);
   ext=deblank(Header.fname);
   ext=ext(end-3:end);
   SubjDir=FG_separate_files_into_name_and_path(deblank(Header.fname(1,:)));
   [root_dir,subj_name]=FG_sep_group_and_path(SubjDir);
   SubjDir=fullfile(root_dir,'FC_ROI_AllVox');
   % output dir
   mkdir(SubjDir);
end

if exist('mask','var')==1
    if ischar(mask)
       mask=FG_read_vols(mask);
    end
end


if size(ROI_TC,2)~=1
    fprintf('\n---This function only deal with 1 ROI timecourses!')
    return
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
clear mask


%      retrieving the ROI averaged time course manualy
%         maskROI =find(maskROI);
%         Vol_4D=reshape(Vol_4D,[],nDim4);
%         ROI_TC(:, x)=mean(Vol_4D(maskROI,:),1)';
%         Vol_4D=reshape(Vol_4D,nDim1,nDim2,nDim3,nDim4);
% 
%         Apply Mask
%         mask =logical(mask);%Revise the mask to ensure that it contain only 0 and 1
%         mask =	repmat(mask, [1, 1, 1, sampleLength]);
%         Vol_4D(~mask)=0;
%         clear mask

%             % tic
%                 %% use: r(x,y)=zscore(x)*zscore(y)/(n-1)
%                 % Divide to pieces to calculate the std for the memory limit
%                     % Vol_4D_zscore = squeeze(std(Vol_4D, 0, 4));    
%                 Vol_4D_zscore=zeros(nDim1, nDim2, nDim3,nDim4);
%                 NSlice_Dim1 =10; % calculate NSlice_Dim1=10 slices of Dim1 each time 
%                 NPiece =ceil(nDim1/NSlice_Dim1); % then need to repeate NPiece to cover the whole Dim1
%                 for iPiece=1:NPiece
%                     if iPiece<NPiece
%                         PieceVolume=Vol_4D((iPiece-1)*NSlice_Dim1+1:iPiece*NSlice_Dim1,:,:,:);
%                         Vol_4D_zscore((iPiece-1)*NSlice_Dim1+1:iPiece*NSlice_Dim1,:,:,:)= zscore(PieceVolume, 0, 4);
%                     else
%                         PieceVolume=Vol_4D((iPiece-1)*NSlice_Dim1+1:nDim1,:,:,:);
%                         Vol_4D_zscore((iPiece-1)*NSlice_Dim1+1:nDim1,:,:,:)= zscore(PieceVolume, 0, 4);
%                     end
%                 end
%                 clear PieceVolume
% 
%                 ROI_TC_zscore=zscore(ROI_TC,0,1);
%                 Vol_4D_zscore =reshape(Vol_4D_zscore, nDim1*nDim2*nDim3, nDim4); 
%                 ROI_TC_zscore =ROI_TC_zscore';
%                 Vol_4D_zscore=Vol_4D_zscore';
%                 Vol_Corr1=ROI_TC_zscore*Vol_4D_zscore/(nDim4 -1);
%                 Vol_Corr1(find(isnan(Vol_Corr1)))=0;
%                 Vol_Corr1=reshape(Vol_Corr1', nDim1, nDim2, nDim3);
%                 toc

        tic
      % use: r(x,y)=(X-Xmean)(Y-Ymean)/((n-1)*XSTD*YSTD)
        %Remove the mean along Dim4
        ROI_TC =ROI_TC -repmat(mean(ROI_TC,1), size(ROI_TC,1), 1);
        Vol_4D = Vol_4D - repmat(mean(Vol_4D,4),[1, 1, 1, nDim4]);


        % Divide to pieces to calculate the std for the memory limit
            % Vol_STDRaw= squeeze(std(Vol_4D, 0, 4));    
        Vol_STDRaw=zeros(nDim1, nDim2, nDim3);
        NSlice_Dim1 =10; % calculate NSlice_Dim1=10 slices of Dim1 each time 
        NPiece =ceil(nDim1/NSlice_Dim1); % then need to repeate NPiece to cover the whole Dim1
        for iPiece=1:NPiece
            if iPiece<NPiece
                PieceVolume=Vol_4D((iPiece-1)*NSlice_Dim1+1:iPiece*NSlice_Dim1,:,:,:);
                Vol_STDRaw((iPiece-1)*NSlice_Dim1+1:iPiece*NSlice_Dim1,:,:)= std(PieceVolume, 0, 4);
            else
                PieceVolume=Vol_4D((iPiece-1)*NSlice_Dim1+1:nDim1,:,:,:);
                Vol_STDRaw((iPiece-1)*NSlice_Dim1+1:nDim1,:,:)= std(PieceVolume, 0, 4);
            end
        end
        clear PieceVolume
        ROI_TC_STD=std(ROI_TC,0,1);


        % (1*sampleLength) A matrix * B matrix (sampleLength * VoxelCount)
            ROI_TC =ROI_TC';
            Vol_4D =reshape(Vol_4D, nDim1*nDim2*nDim3, nDim4);    
            Vol_4D=Vol_4D';
            Vol_Corr= ROI_TC * Vol_4D /(nDim4 -1);            
            Vol_STD= ROI_TC_STD*Vol_STDRaw;
            Vol_STD(find(Vol_STD==0))=inf;%Suppress NaN to zero when denominator is zero
            Vol_Corr=reshape(Vol_Corr', nDim1, nDim2, nDim3);
            Vol_Corr=Vol_Corr./Vol_STD;  

        toc

%         min(Vol_Corr(:))

    if exist('SubjDir','var')==1
        % write down the final  volumes   
        FCmaps_full_names=fullfile(SubjDir,[sprintf('ROI%.3d_AllVox_%s', 1,subj_name) ext]);    
        FG_write_vol(Header,Vol_Corr,FCmaps_full_names,'float32')  ;
    end

% fprintf('\n----- FC compution is done!')


    if nargout~=0
        if exist('SubjDir','var')~=1
            FCmaps_full_names=[];
        end
        varargout={FCmaps_full_names,Vol_Corr};
    end     

