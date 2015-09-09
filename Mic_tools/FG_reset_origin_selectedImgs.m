function FG_reset_origin_selectedImgs(imgs)

%% modified from the SPM8 function : spm_image
% Just for SPM8/5

    if nargin==0
       imgs = spm_select(inf,'image', 'Select imgs for reseting origins...',[],pwd,'.*'); 
    end

    P=imgs;
    % P = spm_select(Inf, 'image','Images to reset orientation of'); 

    for i=1:size(P,1),
        V    = spm_vol(deblank(P(i,:)));
        M    = V.mat;
        vox  = sqrt(sum(M(1:3,1:3).^2));
        if det(M(1:3,1:3))<0, vox(1) = -vox(1); end;
        orig = (V.dim(1:3)+1)/2;
                off  = -vox.*orig;
                M    = [vox(1) 0      0      off(1)
                0      vox(2) 0      off(2)
                0      0      vox(3) off(3)
                0      0      0      1];
        spm_get_space(P(i,:),M);

    end;
    
    fprintf('\n   ---- Origin reseting is done...\n')

    
   % tmp = spm_get_space([st.vols{1}.fname ',' num2str(st.vols{1}.n)]);
   % if sum((tmp(:)-st.vols{1}.mat(:)).^2) > 1e-8,
   %     spm_image('init',st.vols{1}.fname);
   % end;

