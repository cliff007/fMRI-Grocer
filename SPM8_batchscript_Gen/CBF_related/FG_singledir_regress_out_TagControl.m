function FG_singledir_regress_out_TagControl(imgs,order)
   if nargin==0
        imgs =  spm_select(inf,'any','Select all the perfusion imgs you want to deal with', [],pwd,'.*img$|.*nii$');
        if isempty(imgs), return;   end
        order = questdlg('Select a kind of label-control order for your perfusion imgs','label-control order selection...','Tag->Control','Control->Tag','Tag->Control') ;
   end
    
    [Vs,Vmat]=FG_read_vols(imgs);
    
%     n = size(imgs,1);
%     TagCtr=-ones(n,1);           %% cliff:  should be switched later to allow different label control order, now assume first image is label (-1), and the second is the control (1)
%     TagCtr(2:2:end)=1;
%     if strcmp(order,'Control->Tag')
%         TagCtr=-TagCtr;
%     end



    % TagCtr=repmat(1,size(Vs));
    ref=-ones(size(Vs,4),1);   %% cliff:  should be switched later to allow different label control order, now assume first image is label (-1), and the second is the control (1)
    ref(2:2:end)=1;
    if strcmp(order,'Control->Tag')
        ref=-ref;
    end

    
% a=b*X+E , % orginal regression formular
    % X=b\a  , % coefficient ; A\B is roughly the same as inv(A)*B
    % E=a-b\a*b ,% residual

    % Vs_tem=reshape(Vs,prod(size(Vs(:,:,:,1))),size(Vs,4)); 
    % Vs_tem=reshape(Vs,numel(Vs(:,:,:,1)),size(Vs,4));  


Residual =RegressOutCovariables_4D(Vs, ref);
        %         % regress out ref from Vs
        %         for i=1:pr
        %             coefs=ref\Vs;
        %             residuals=Vs-ref*coefs;    
        %             residuals=VS-ref*ref\Vs   
        %         end

for i=1:size(Vs,4)
   name_tem=Vmat(i,1).fname;
   [new_path,new_fullname]=FG_create_new_outputdir(name_tem,'Regressed_TagCtrl');
   mkdir (new_path)
   FG_write_vol(Vmat(i,1),Residual(:,:,:,i),new_fullname) ;    
end
  
    


fprintf('\nTag-Control variable has been regressed out from perfusion images...\n\n')




function Residual =RegressOutCovariables_4D(Vs, ref)
    % Regress some covariables out first	
    %  resd=Vs-ref/(ref'*ref)*ref'*Vs;  % from Ze Wang
	[nDim1, nDim2, nDim3, nDim4]=size(Vs);
	
	% Make sure the 1st dim of ref is nDim4 long
	if size(ref,1)~=nDim4, error('The length of Covariable doesn''t match with the volume.'); end
	
	% (1*sampleLength) A matrix * B matrix (sampleLength * VoxelCount)
	Vs =reshape(Vs, nDim1*nDim2*nDim3, nDim4)';
	Residual=(eye(nDim4) - ref * inv(ref' * ref)* ref') * Vs;
    % <==> Residual = Vs - ref * inv(ref' * ref)* ref' * Vs;
	Residual =reshape(Residual', nDim1, nDim2, nDim3, nDim4);
    
    