function Resid = FG_RegressOutCovariables_from_vol(Vol,Covariates)
%% you need to add consistent-item (a column of 1) to the original
%% covariates before use this function
%         if nargin==0
%         %     imgs=['ROI1FCMap_01_HZQ.hdr';
%         %         'ROI1FCMap_02_CZM.hdr'];
% 
%             imgs=['ROI1FCMap_01_HZQ.hdr'];    
%             Vol=FG_read_vols(imgs);
%             Covariates=[1.3 2.5]';
%         end
% 
%         Vol=reshape(Vol, prod(size(Vol)), 1);
%         Covariates=rand(length(Vol),1);

tem=size(Vol);
if size(tem,2)==4
    Resid  =Volume4D_RegressOutCovariates(Vol, Covariates);    
elseif size(tem,2)==2 && size(Vol,2)==1
    Resid  =Volume1D_RegressOutCovariates(Vol, Covariates);
end


function Resid  =Volume4D_RegressOutCovariates(Vol_4D, Covariates)
% Residual calculating: Residual =(E - X*inv(X'*X)*X')*Y
	[nDim1, nDim2, nDim3, nDim4]=size(Vol_4D);	
	%Make sure the 1st dim of Covariates is nDim4 long
	if size(Covariates,1)~=nDim4, error('The length of Covariates don''t match with the volume.'); end
	
	% (1*sampleLength) A matrix * B matrix (sampleLength * VoxelCount)
	Vol_4D =reshape(Vol_4D, nDim1*nDim2*nDim3, nDim4)'; % reshape the vol into (vector x Time) variable
	Resid  =(eye(nDim4) - Covariates * inv(Covariates' * Covariates)* Covariates') * Vol_4D;
	Resid  =reshape(Resid, nDim1, nDim2, nDim3, nDim4);
    fprintf('');    
    
    
function Resid  =Volume1D_RegressOutCovariates(Vol_1D, Covariates)
% Residual calculating: Residual =(E - X*inv(X'*X)*X')*Y
	%Make sure the input is a column vector
        % 	Vol_1D =reshape(Vol_1D, prod(size(Vol_1D)), 1);
	
	%Make sure the 1st dim of Covariates is nDim4 long
	if size(Covariates,1)~=length(Vol_1D), error('The length of Covariates don''t match with the volume.'); end
	
	% (1*sampleLength) A matrix * B matrix (sampleLength * VoxelCount)	
	Resid  =(eye(size(Vol_1D, 1)) - Covariates * inv(Covariates' * Covariates)* Covariates') * Vol_1D;
	fprintf('');  
    
    
    