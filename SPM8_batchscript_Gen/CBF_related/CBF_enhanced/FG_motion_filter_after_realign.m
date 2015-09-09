function [fileout]=FG_motion_filter_after_realign(files_after_realign,sub_dir)    
    if nargin ==0        
        files_after_realign = spm_select(inf,'.nii|.img$','Select all the r*.img which are after realignment', [],pwd,'^r.*img$|^r.*nii$'); 
        if FG_check_ifempty_return(files_after_realign), return;end
        [a,b,c,d]=fileparts(files_after_realign(1,:));
        sub_dir=a;
        cd (a)
    elseif nargin ==1
        [a,b,c,d]=fileparts(files_after_realign(1,:));
        sub_dir=a;
        cd (a)
    end

    P=files_after_realign;
    out_fix='motion_filtered_';
    mask_name='EPI_mask_for_motion_filter.nii';
    if size(P,1)==1,return;end   % return when there is only one img uder subj's folder

    % Ptmp=spm_select('FPList', PAR.subs(sb).ses(nse).condirs{jj}, ['^r' PAR.imgfilters{jj} '\w*.*\.img$']);
    % P=strvcat(P,Ptmp);
    v=spm_vol(P);
    dat=spm_read_vols(v);
    % cd(PAR.subs(sb).ses(nse).condirs{1});

    % create a mean_img of all realigned imgs
    maskfile=fullfile(sub_dir,mask_name);
    if exist(maskfile,'file')==0   % when non-existed
        mask=mean(dat,4); % great! mean at the Dim4
        mask=mask>0.25*max(mask(:));  % threshold the mean-img at [0.25*max(mask(:))]
        vo=v(1);
        vo.fname=maskfile;
        vo=spm_write_vol(vo,mask);
    % maskfile=fullfile(PAR.subs(sb).ses(nse).condirs{1},'EPI_mask.nii');
    end

    % if size(P,1)==1,continue;end

    % read the new created mask
    vm=spm_vol(maskfile);
    mask=spm_read_vols(vm);
    Xdim=size(dat,1);
    Ydim=size(dat,2);
    Zdim=size(dat,3);
    Tdim=size(dat,4);
    dat=reshape(dat,Xdim*Ydim*Zdim,Tdim);  % reshape the image-value matrix into a two-Dims array

    idx=find(mask>0); % find the ROI regions within the mask
    dat=dat(idx,:)'; % Be careful: this will filter the "dat" matrix at each column, dat=dat(idx) will only apply the filter at the first column
    avgdat=mean(dat,1); % mean(A,1) is a row vector containing the mean value of each column.   % get the mean value of each voxel within the mask across all input-imgs
    dat=dat-repmat(avgdat,Tdim,1); % each voxel value of each input-img substract a mean-voxel-value-across inputs within the mask;   this will be added back below
    ref=-ones(size(P,1),1);
    ref(2:2:end)=1; % ref is just a temporary vector for the following orthogonalization procedure

    movefil = spm_select('FPList',sub_dir, ['^rp_\w*.*.txt']); % read and load the rp*.txt file which contains the motion parameters
    if size(movefil,1)>1,
        fprintf('\nI can decide which rp*.txt file to use!\n')
        h_GOnoGo=questdlg(sprintf(['If you want to continue,the first file: \n' ,movefil(1,:) ,'\nwill be used!']),'Hi....','Yes','No','Yes') ;
        if strcmp(h_GOnoGo,'Yes')
           fprintf('\nLet''s go ahead!\n')
        else
           return
        end
    elseif size(movefil,1)==0,
        fprintf('\nI can''t find a rp*.txt file to use!\n')
        return
    end   % return when there are no rp*.txt file
    
    moves = spm_load(movefil(1,:));

    refs=cat(2,ref,moves(1:size(P,1),:));
    refs=FG_cgrscho_orthogonalization(refs);  %  orthogonalize label-control variable(ref) and the 6 motion-paras to make these 7 variables has no correlation anymore
    refs=refs(:,2:end);    % abandon the first column derived from "ref" vector
    beta=refs\dat;  %  X = A\B is the solution to the equation AX = B computed by Gaussian elimination; 
                    %  assume:  dat= refs* beta + error, first, use non-error regression (refs*beta=dat) ==> (beta = refs\dat) to get (beta),
    dat=dat-refs*beta; %%  then (dat-refs*beta) is the residual of the dat that exclude the influence of ref variable (label-control)
    cutoff=0.4;               
    [lb,la]=FG_fltbutter_filter(1,cutoff,'high');  % high frequency filter
    clear filter
    dat=filter(lb,la,dat',[],2);   % be careful: "filter" function
    dat=dat'+repmat(avgdat,Tdim,1);  % add the mean-value back
    dat=dat';

    for im=1:size(P,1)
        imgbuf=zeros(Xdim,Ydim,Zdim);
        imgbuf(idx)=dat(:,im);
        v(im).fname=fullfile(spm_str_manip(v(im).fname,'H'),[out_fix spm_str_manip(v(im).fname,'ts') '.nii']);   % write the new image after motion-filter
        v(im)=spm_write_vol(v(im),imgbuf);
    end

    [a,b,c,fileout]=FG_separate_files_into_name_and_path(files_after_realign,out_fix,'prefix','.nii'); % replace the ext with ".nii"
    
    