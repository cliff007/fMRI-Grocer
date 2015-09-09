function [Q,Vo]=FG_reslice_image_into_target_space(ref_img,source_img,datat,intp)
if nargin<2
    ref_img = spm_select(1,'image','Select the reference image as the target');
    source_img = spm_select(1,'image','Select the source image which is needed to be resliced');

    h=questdlg('Specify interpolation scheme and datatype:','Choose one scheme...','1.For normal imgs','2.For binary imgs','3.Specify myself','1.For normal imgs') ;
    switch h
        case '3.Specify myself'
            dlg_prompt={'Interpolation shceme(0 for NearestNeighbor, 1 for Trilinear, etc.):','Datatype:                               '};
            dlg_name='Specify Parameters...';
            dlg_def={'1','4'};
            Ans=inputdlg(dlg_prompt,dlg_name,1,dlg_def); 
            intp=Ans{1};
            datat=Ans{2};
        case '1.For normal imgs'
            intp='1';
            datat='4';                
        case '2.For binary imgs'
            intp='0';
            datat='8';   % 16 may cause some NaN values, 8 is OK!             
    end
elseif nargin==2
    intp='1';
    datat='4';    
end

P=strvcat(ref_img,source_img);
f='i2';
flags={0,0,str2num(datat),str2num(intp)};

[a,b,c,d]=fileparts(deblank(source_img));
refData=spm_read_vols(spm_vol(deblank(ref_img)));
Q = fullfile(a,['resliced_' b '_as_' num2str(size(refData,1)) 'x' num2str(size(refData,2)) 'x' num2str(size(refData,3)) c]);

[Q,Vo] = FG_spm_imcalc_ui(P,Q,f,flags);