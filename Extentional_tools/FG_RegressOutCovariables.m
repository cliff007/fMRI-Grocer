function Covs_removed_full_names = FG_RegressOutCovariables(fullpath_imgs,mask,Covariates,Covariates_polort)
%%   Input:
%%      Covariates:  just use the original covariates, No need to add consistent-item manually
%%      Covariates_polort - The order of the polynomial which adding to baseline model according to 3dfim+.pdf. Recommend: 1.
%%   Output:
%%      *.nii - data removed the effect of Covariates.

%             if nargin==0
%                 cd ('E:\ToPN_AC_3T_20CH_201501_Nii\nontopo_frist\20150106_K4_TOPO_AC_S005\006_ep2d_bold_moco_TR2560_iPAT2_REST_150')
%                 fullpath_imgs=['20150106_134352ep2dboldmocoTR2560RESTiPAT2s006a001_146.nii'  ;
%                 '20150106_134352ep2dboldmocoTR2560RESTiPAT2s006a001_147.nii'  ;
%                 '20150106_134352ep2dboldmocoTR2560RESTiPAT2s006a001_148.nii'  ;
%                 '20150106_134352ep2dboldmocoTR2560RESTiPAT2s006a001_149.nii' ; 
%                 '20150106_134352ep2dboldmocoTR2560RESTiPAT2s006a001_150.nii';];
% 
%                 mask=FG_read_vols('20150106_134352ep2dboldmocoTR2560RESTiPAT2s006a001_150.nii');
% 
%                 Covariates=rand(5,6);
% 
%                 Covariates_polort=0; % default value; 
%                                      % use to construct constant-item for regression in different order(½×)
%                                      % when Covariates_polort=0, a constant-item =ones(x,1) will be constructed as below
%             end
                     



% get the subj dir
SubjDir=FG_separate_files_into_name_and_path(fullpath_imgs(1,:));
% SubjDir=pwd;

% read images
[AllVolume,Header,theImgFileList,VoxelSize]=FG_read_vols(fullpath_imgs);
    %% all the images shoud have the same voxelsize and basic header info
    Header=Header(1);
    ext=deblank(Header.fname);
    ext=ext(end-3:end);
    VoxelSize=VoxelSize(1,:);

% examine the dimensions of the functional images
nDim1 = size(AllVolume,1); nDim2 = size(AllVolume,2); nDim3 = size(AllVolume,3); nDim4 =size(AllVolume,4);
sampleLength =size(theImgFileList,1);

%Add polynomial in the baseline model according to 3dfim+.pdf   
    %% you need to add consistent-item (a column of 1) to the original
    %% covariates before use "FG_RegressOutCovariables_from_vol"
if Covariates_polort>=0,
    thePolOrt =(1:sampleLength)';
    thePolOrt =repmat(thePolOrt, [1, (1+Covariates_polort)]);
    for x=1:(Covariates_polort+1),
        thePolOrt(:, x) =thePolOrt(:, x).^(x-1) ;
    end
end
Covariates =[thePolOrt, Covariates];


% set mask
mask =logical(mask); % ensure that it contain only 0 and 1	
mask =	repmat(mask, [1, 1, 1, sampleLength]);	
AllVolume=AllVolume.*mask;

fprintf('\nRegressing Out Covariates:\n');   
% separate and save the 4D dataset along the 1st dimension to reduce the load of memory
fprintf('\nCaculating...')
for x=1:nDim1    
    oneAxialSlice =double(AllVolume(x, :, :, :));
%     oneAxialSlice =Volume4D_RegressOutCovariates(oneAxialSlice,Covariates);
    %% you need to add consistent-item (a column of 1) to the original
    %% covariates before use "FG_RegressOutCovariables_from_vol"
    oneAxialSlice_Resid = FG_RegressOutCovariables_from_vol(oneAxialSlice,Covariates);
    AllVolume(x, :, :, :) =(oneAxialSlice_Resid);
end;

% output dir
SubjDir =sprintf('%s%s',SubjDir,'_CovRemoved');
ans=rmdir(SubjDir, 's');%suppress the error msg
mkdir(SubjDir);

% write down the final  volumes   
Covs_removed_full_names=[];
for x=1:sampleLength
    new_full_name=fullfile(SubjDir,[sprintf('%s%.8d','Coved', x) ext]);    
    FG_write_vol(Header,AllVolume(:, :, :, x),new_full_name,'float32')  ;
    Covs_removed_full_names=strvcat(Covs_removed_full_names,new_full_name);
end
fprintf('...done...\n');
