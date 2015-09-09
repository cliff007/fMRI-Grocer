function varargout=FG_get_SPM_TMVV_and_TMVV_based_mask(V,varargin)
%% the input can only be 3D volume matrix    
    % calculate the TMVV
        firstpassmean  = mean(V(:));
        tmp = V(:,:,:) > (firstpassmean/8);
        im_tem=V(tmp);
        TMVV = mean(im_tem(:));  % this is the TMVV  <<====>> actually, TMVV=spm_global(spm_vol('img'))
        % TMVV1=spm_global(V(:));
        
    if nargin==2
        thresh=varargin{1};
        TMVV_mask=V> thresh*TMVV; 
        TMVV_masked_img=V.*(V> thresh*TMVV);   
    elseif nargin==3
        thresh1=varargin{1};
        thresh2=varargin{2};
        TMVV_mask1=(V(:,:,:) > thresh1*TMVV);
        TMVV_mask2=(V(:,:,:) < thresh2*TMVV);
        TMVV_mask=TMVV_mask1.*TMVV_mask2;
        TMVV_masked_img= V.*(thresh1*TMVV < V(:,:,:) <thresh2*TMVV); 
    end

    
    if nargin==1 && nargout~=0
        varargout={TMVV};
    elseif nargin>1 && nargout~=0
        varargout={TMVV_mask,TMVV_masked_img,TMVV};
    end