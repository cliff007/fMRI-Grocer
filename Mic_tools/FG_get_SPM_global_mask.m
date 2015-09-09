function varargout=FG_get_SPM_global_mask(img,outdir)
%% the input can be either a file name or a 3D-matrix, or the result of spm_vol
    if nargin==0
       img=spm_select(1,'image','Select an images...',[],pwd,'^p.*'); 
    end    
            
    if ischar(img)
        Vmat=spm_vol(deblank(img));
        V=spm_read_vols(Vmat);
    elseif isstruct(img)
        Vmat=img;
        V=spm_read_vols(Vmat);
    elseif length(size(img))==3
        V=img;
    end
    
    
    % use spm_global to calculte the spm-global mean
    
    
    if ischar(img) || isstruct(img)
%         GlobalM=spm_global(V);  
        tem_M=mean(V(:))/8;
        maskY(:,:,:)=V(:,:,:)>=tem_M;
        [a,b,c,d]=fileparts(deblank(img));
        Vmat_out=Vmat;
        if nargin==0 || nargin==1
           Vmat_out.fname=fullfile(pwd,['SPM_Global_mask_of_',b,'.nii']);
        elseif nargin ==2
           Vmat_out.fname=fullfile(outdir,['SPM_Global_mask_of_',b,'.nii']);
        end
        spm_write_vol(Vmat_out,maskY);
        fprintf('\n ---%s is created under %s\n',Vmat_out.fname)
    else
        tem_M=mean(V(:))/8;
        maskY(:,:,:)=V(:,:,:)>tem_M;   
        fprintf('\n ---SPM_Global_mask volume is created\n')
    end      
    
    
    if nargout==1
        varargout={maskY};
    end