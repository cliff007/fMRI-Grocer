function varargout = FG_correlation_ROIMulti_AllVoxels_fast(ROI_TCs,Vol_4D,mask)
% Functional connectivity: cliff 2015
% ROI_TCs: each column represents a timecourse of a ROI, and the column num should be bigger than 2
    %% In this script calculate the voxelwise correlation coefficient by manipulating the maxtix 
    %% with the textbook definition of r (rather than use "corrcoef") to faster the calculation
    %% r(x,y)=(X-Xmean)(Y-Ymean)/((n-1)*XSTD*YSTD)
    %% r(x,y)=zscore(x)*zscore(y)/(n-1),

if nargin==0
    cd ('D:\FunImgRWSDFC\01_HZQ');
    imgs=FG_list_all_files('D:\FunImgRWSDFC\01_HZQ','*','*img');
    Vol_4D=FG_read_vols(imgs);
    ROI_TCs=Vol_4D(25:29,30,20,:);
    ROI_TCs=squeeze(ROI_TCs)';    
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
   SubjDir=fullfile(root_dir,'FC_ROIs_AllVox');
   % output dir
   mkdir(SubjDir);
end
if exist('mask','var')==1
    if ischar(mask)
       mask=FG_read_vols(mask);
    end
end


if size(ROI_TCs,2)<2
    fprintf('\n---This function only deal with at least 2 ROI timecourses!')
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

N_TCs=size(ROI_TCs,2);

%         tic
            % use: r(x,y)=(X-Xmean)(Y-Ymean)/((n-1)*XSTD*YSTD) 
            % Remove the mean along Dim4
            ROI_TCs =ROI_TCs -repmat(mean(ROI_TCs,1), size(ROI_TCs,1), 1);
            Vol_4D = Vol_4D - repmat(mean(Vol_4D,4),[1, 1, 1, nDim4]);


            % Divide to pieces to calculate the std for the memory limit
                % Vol_STDRaw= squeeze(std(Vol_4D, 0, 4));    
            Vol_STDRaw=zeros(nDim1, nDim2, nDim3);
            NSlice_Dim1 =10; % calculate NSlice_Dim1=10 slices of Dim1 each time 
            NPiece =ceil(nDim1/NSlice_Dim1); % then need to repeate NPiece to cover the whole Dim1
            for iPiece=1:NPiece
                if iPiece<NPiece
                    PieceVolume=Vol_4D((iPiece-1)*NSlice_Dim1+1:iPiece*NSlice_Dim1,:,:,:);
                    Vol_STDRaw((iPiece-1)*NSlice_Dim1+1:iPiece*NSlice_Dim1,:,:)= squeeze(std(PieceVolume, 0, 4));
                else
                    PieceVolume=Vol_4D((iPiece-1)*NSlice_Dim1+1:nDim1,:,:,:);
                    Vol_STDRaw((iPiece-1)*NSlice_Dim1+1:nDim1,:,:)= squeeze(std(PieceVolume, 0, 4));
                end
            end
            clear PieceVolume
            ROI_TC_STD=std(ROI_TCs,0,1);


            % (1*sampleLength) A matrix * B matrix (sampleLength * VoxelCount)
                ROI_TCs =ROI_TCs';
                Vol_4D =reshape(Vol_4D, nDim1*nDim2*nDim3, nDim4);    
                Vol_4D=Vol_4D';
                Vol_Corr= ROI_TCs * Vol_4D /(nDim4 -1);
                Vol_STDRaw=reshape(Vol_STDRaw, nDim1*nDim2*nDim3,1)';
                ROI_TC_STD=ROI_TC_STD';
                Vol_STD= ROI_TC_STD*Vol_STDRaw;
                Vol_STD(find(Vol_STD==0))=inf;%Suppress NaN to zero when denominator is zero
                Vol_Corr=Vol_Corr./Vol_STD; 
                
%             min(Vol_Corr(1,:))
%             min(Vol_Corr(2,:))
                
                Vol_Corr=reshape(Vol_Corr', nDim1,nDim2,nDim3, N_TCs); 

%         toc

if exist('SubjDir','var')==1
    % write down the final  volumes   
    ROIs_AllVox_full_names=[];
    for x=1:N_TCs
        new_full_name=fullfile(SubjDir,[sprintf('ROI%.3d_AllVox_%s', x,subj_name) ext]);    
        FG_write_vol(Header,Vol_Corr(:, :, :, x),new_full_name,'float32')  ;
        ROIs_AllVox_full_names=strvcat(ROIs_AllVox_full_names,new_full_name);
    end
end


% fprintf('\n----- FC compution is done!')


    if nargout~=0
       if exist('SubjDir','var')~=1
           ROIs_AllVox_full_names=[];
       end
       varargout={ROIs_AllVox_full_names,Vol_Corr};
    end     
