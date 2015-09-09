function varargout =FG_singledir_imgs_cal_avgODD_and_even_separately(imgs,outdir)

if nargin==0
    imgs =  spm_select(inf,'any','Select all the imgs you want to dealwith', [],pwd,'.*img$|.*nii$');
elseif nargin==1
    Vmat_out=spm_vol(imgs(1,:)); %% all outputs will be in the same folder as the first image
    [a,b,c,d]=fileparts(Vmat_out.fname);
    outdir=a;
end

if FG_check_ifempty_return(imgs), return; end
if mod(size(imgs,1),2)~=0, fprintf('\n---The number of the selected images is not even!\n'), return; end

imgs_odd=imgs(1:2:end,:);
imgs_even=imgs(2:2:end,:);

 Vmat_out=spm_vol(imgs(1,:)); %% all outputs will be in the same folder as the first image

% outputs
Vmat_out.fname=fullfile(outdir, 'OE_avg_odd_EPI.nii');
 spm_imcalc(spm_vol(imgs_odd),Vmat_out,'sum(X)/size(X,1)',{1,0,0}); 
% Vmat_out.fname=fullfile(outdir, 'OE_Sum_odd_EPI.nii');
%  spm_imcalc(spm_vol(imgs_odd),Vmat_out,'sum(X)',{1,0,0});

Vmat_out.fname=fullfile(outdir, 'OE_avg_even_EPI.nii');
 spm_imcalc(spm_vol(imgs_even),Vmat_out,'sum(X)/size(X,1)',{1,0,0}); 
% Vmat_out.fname=fullfile(outdir, 'OE_Sum_even_EPI.nii');
%  spm_imcalc(spm_vol(imgs_even),Vmat_out,'sum(X)',{1,0,0}); 

Vmat_out.fname=fullfile(outdir, 'OE_Difference_Odd_Even_EPI.nii');
imgs_tem=strvcat(fullfile(outdir, 'OE_avg_odd_EPI.nii'),fullfile(outdir, 'OE_avg_even_EPI.nii'));
 spm_imcalc(spm_vol(imgs_tem),Vmat_out,'i1-i2' ,{0,0,0}); 

Vmat_out.fname=fullfile(outdir, 'OE_Difference_Even_Odd_EPI.nii');
imgs_tem=strvcat(fullfile(outdir, 'OE_avg_even_EPI.nii'),fullfile(outdir, 'OE_avg_odd_EPI.nii'));
 spm_imcalc(spm_vol(imgs_tem),Vmat_out,'i1-i2' ,{0,0,0}); 

Vmat_out.fname=fullfile(outdir, 'OE_avg_all_EPI.nii');
imgs_tem=strvcat(fullfile(outdir, 'OE_avg_odd_EPI.nii'),fullfile(outdir, 'OE_avg_even_EPI.nii'));
 spm_imcalc(spm_vol(imgs_tem),Vmat_out,'(i1+i2)/2' ,{0,0,0}); 

if nargout==0
    fprintf('\n----Outputs are images(OE_*.img/nii; O-Odd, E-Even) that are under the %s \n\n',a)
elseif nargout==1
    varargout={
        strvcat(fullfile(outdir, 'OE_avg_odd_EPI.nii'),...      %% avg_odd
        fullfile(outdir, 'OE_avg_even_EPI.nii'),...             %% avg_even
        fullfile(outdir, 'OE_Difference_Odd_Even_EPI.nii'),...  %% Difference_Odd_Even
        fullfile(outdir, 'OE_Difference_Even_Odd_EPI.nii'),...     %% Difference_Even_Odd
        fullfile(outdir, 'OE_avg_all_EPI.nii'))                    %% Average of all
        } ;
end

