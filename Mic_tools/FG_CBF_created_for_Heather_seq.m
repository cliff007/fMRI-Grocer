function FG_CBF_created_for_Heather_seq(ASL_imgs)
if nargin==0
   ASL_imgs =spm_select(inf,'.img|.nii','Select the Original ASL images acquired by Heather''s sequence', [],pwd,'.*');
end

n=size(ASL_imgs,1);

% ASL image series confirming
if mod(n,2)
    fprintf('\n----Abandon the last ASL image...\n')
    ASL_imgs = ASL_imgs(1:end-1,:);
    n1=n-1;
else
    n1=n;
end

%%% CBF generating
ASL_imgs_odd = ASL_imgs(1:2:end,:); % label images
ASL_imgs_even = ASL_imgs(2:2:end,:); % control images

[V1,Vmat]=FG_read_vols(ASL_imgs_odd);
[V2,Vmat]=FG_read_vols(ASL_imgs_even);
Vmat=Vmat(1);

V=(V1-V2)./V2;
for i=1:n1/2
    new_name=FG_simple_rename_untouch(Vmat.fname,sprintf('Heather_CBF_%0.5d.nii',i),'_CBF');
    FG_write_vol(Vmat,V(:,:,:,i),new_name)  
end

fprintf('\n----Done...\n')



