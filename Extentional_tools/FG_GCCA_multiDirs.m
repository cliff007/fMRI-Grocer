function FG_GCCA_multiDirs(rootdir,subdirs,filefilter,brain,ROIs,Val_range_low,Val_range_up,NLAGS,PVAL,Fs,freqs,htype)
    if nargin==0
        rootdir=spm_select(1,'dir','Select the root folder of multiple subfolders');
        if isempty(rootdir), return, end

        subdirs=spm_select(inf,'dir','Select the multiple subfolders');
        if isempty(subdirs), return, end

        filefilter=inputdlg('Enter a file filter to select files under each subfolder:','File fileter...',1,{'.*img'})   ;
        filefilter= filefilter{1} ;      
    
        %  initial GCCA parameters 
        PVAL    =   0.01;       % probability threshold for Granger causality significance
        NLAGS   =   -1;         % if -1, best model order is assessed automatically
        Fs      =   500;        % sampling frequency  (for spectral analysis only)
        freqs   =   [1:100];    % frequency range to analyze (spectral analysis only)
        Val_range_low=0;
        Val_range_up=inf;

        htype=questdlg('Voxel-wise or ROI-wise?', 'Hi...','Voxel-wise','ROI-wise','ROI-wise') ;       

        if  strcmpi(htype,'ROI-wise') 
            ROIs = spm_select([2,Inf],'any','Select ROIs(At least two for ROI-wise)', [],pwd,'.*img$|.*nii$');
            if isempty(ROIs), return, end
            if size(ROIs,1)<2, return, end
        else
            ROIs = spm_select(inf,'any','Select ROIs(If more than one, will do GCCA for ROIs one by one)', [],pwd,'.*img$|.*nii$'); 
            if isempty(ROIs), return, end
        end

        brain = spm_select(1,'any','Select a whole brain mask,or skip this step~', [],pwd,'.*img$|.*nii$');

    end
     
    cd (rootdir)    

 
    for i=1:size(subdirs,1)        
        imgs = spm_select('FPList',deblank(subdirs(i,:)),filefilter);
        if isempty(imgs)
            fprintf('\n !!!!!!!! No imgs under %s...\n',deblank(subdirs(i,:)))  
            continue
        end

        [GC2,causf_flow,causd_ucdw]=FG_GCCA_single(imgs,brain,ROIs,Val_range_low,Val_range_up,NLAGS,PVAL,Fs,freqs,htype);
        fprintf('\n ------- GCCA of  %s is done...\n',deblank(subdirs(i,:)))   
    end
    
    fprintf('\n-------GCCA of all selected subjects are done...\n')  


