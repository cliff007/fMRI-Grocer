function FG_outlier_clean_after_CBF(CBF_files,sub_dir)   
    if nargin ==0        
        CBF_files = spm_select(inf,'.nii|.img$','Select all the r*.img which are after realignment', [],pwd,'^CBF.*img$|^CBF.*nii$'); 
        if FG_check_ifempty_return(CBF_files), return;end
        [a,b,c,d]=fileparts(CBF_files(1,:));
        sub_dir=a;
        cd (a)
        [sub_dir_path,sub_dir_name]=FG_sep_group_and_path(sub_dir);
    elseif nargin ==1
        [a,b,c,d]=fileparts(CBF_files(1,:));
        sub_dir=a;
        cd (a)
        [sub_dir_path,sub_dir_name]=FG_sep_group_and_path(sub_dir);
    else
        [sub_dir_path,sub_dir_name]=FG_sep_group_and_path(sub_dir);
    end
    
   files =CBF_files;
   n_img=size(files,1);

   movefil=spm_select('FPList', sub_dir, ['^rp_\w*\.txt$']);
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
    
    % getting realignment parameters

    Params =[];
    for ii=1:size(movefil,1)
        Params=[Params; textread(deblank(movefil(ii,:)))];  % "spm_load" is good to replace the "textread"
    end
    
    if size(Params,1) > 2*n_img  %% For instance: totally 79 original imgs, then only (79-1)/2=39 CBF imgs. but there are 79 lines in the rp*.txt file
        Params=Params(1:2*n_img,:);
        fprintf('\nImg number is smaller than the rows of the motion-paras! Take the rows that is twice of the the Imgs at the beginning!\n')        
    elseif size(Params,1) < 2*n_img
        fprintf('\nImg number is bigger than the rows of the motion-paras! File doesn''t match!\n')
        return        
    end
    
    Params(:,4:6)=Params(:,4:6)*180/pi; %  % just for the last 4-6 columns (rotation) of the motion parameters, change its unit into "degree"
    Params=Params(:,1:6);  % read the first 6 columns
    mpara=(Params(1:2:end,:)+Params(2:2:end,:))/2;  % the mean of rows(1 3 5 ...) and rows(2 4 6 ...)  % this is about the labels and controls  
    diffpara=abs(Params(1:2:end,:)-Params(2:2:end,:));  % the difference of rows(1 3 5 ...) and rows(2 4 6 ...) % this is about the labels and controls      
    %% If the average head motion of one pair is greater than 8 ,
    %%          or 
    %% the difference is greater than 2,
    %% then we will treat the pair as a spike.

% % % % % % % Note: the thresholds are still in decision here. 
    filter=abs(mpara)>2;  % now the threshold is 2        
    filter=sum(filter,2);  % sum all columns in row
    filter=filter>0;  % this means: if any mean of translation-x,y,z and rotation-x,y,z has motion that bigger than 2, then this pair is marked in the "filter"

    dfilter=diffpara>1; % now the threshold is 1   
    dfilter=sum(dfilter,2);
    dfilter=dfilter>0;  % this means: if any difference of translation-x,y,z and rotation-x,y,z has motion that bigger than 1, then this pair is marked in the "filter"

    fil=(filter+dfilter)>0;  % new filter %% this is to mark any img that out of threshold in eight mean or difference 


% assuming the CBF images are already thresholded
    %          file=spm_get('files', PAR.condirs{sb,c}, ['meanCBF_' num2str(PAR.subtractiontype) '_s*img']);
    %          if size(file,1)<1, fprintf('No mean CBF image found for %s.\n',PAR.subjects{sb});continue;end
    %          v=spm_vol(file);
    %          siz=v.dim(1:3);
    %          mdat=spm_read_vols(v);
    %          mask=mdat>0;     % background mask
    %          wholemask=abs(mdat)>0;
    %          % using absolute cbf range to mask out the outliers
    %          bmask=(mdat>=20).*(mdat<=180);
    %          mask=bmask.*mask;
    %          files=spm_get('files',PAR.subs(sb).ses(b).condirs{c}, ['cbf_' num2str(PAR.subtractiontype) '_s*img']);



%          files=spm_select('FPList',PAR.subs(sb).ses(b).condirs{c}, ['^cbf_' num2str(PAR.subtractiontype) '_\w*.img']); % read all the CBF imgs

     if size(files,1)<2, fprintf('Not enough images found for %s.\n',sub_dir_name); return;end  % when there is only one image, return the function
     
     %% read out the CBF imgs
     v=spm_vol(files);
     dat=spm_read_vols(v);
     siz=size(dat);
     dat=reshape(dat,siz(1)*siz(2)*siz(3),size(files,1));
     clear gcbf;

    %          for i=1:size(files,1)
    %             dati=squeeze(dat(:,i));
    %             nmask=mask(:)-isnan(dati);
    %             gcbf(i)=mean(dati(find(nmask>0)));
    %             nmask=wholemask(:)-isnan(dati);
    %             wholegs(i)=mean(dati(find(nmask>0)));
    %          end
    %         gcbf=gcbf';
    %          gsfile=fullfile(char(PAR.condirs{sb,c}),PAR.glcbffile);
    %          gsdat=load(gsfile);
    %          gsbuf=zeros(size(files,1),6);
    %          if size(gsdat,2)<4
    %              gsbuf(:,1:3)=gsdat(:,1:3);
    %          else
    %             gsbuf(:,1:4)=gsdat(:,1:4);
    %          end
    %          gsbuf(:,5)=gcbf;
    %          % spike identifying
    %          mgs=mean(gcbf);
    %          stdgs=std(gcbf);
    %          indicator=(gcbf>(mgs-2*stdgs)).*(gcbf<(mgs+3*stdgs));
    %          % second cleaning
    %          mgs=mean(gcbf(find(indicator)));
    %          stdgs=std(gcbf(find(indicator)));
    %          fmgs=gcbf;
    %          fmgs(find(indicator==0))=mgs;
    %          indicator=indicator.*(fmgs>(mgs-2*stdgs)).*(fmgs<(mgs+2*stdgs));
    %          gsbuf(:,6)=1-indicator;
    %          gsbuf(:,7)=fil(offset+(1:size(gsbuf,1)));             % spike indicator calculated from realignment time course
    %          gsbuf(:,6)=(gsbuf(:,6)+(wholegs'>160)+(wholegs'<15))>0;
    %          save(gsfile,'gsbuf','-ascii');
    %          idx=gsbuf(:,6)+gsbuf(:,7)>0;


%%%% only use the head motion information to select which CBF imgs should
%%%% be kept 
     offset=0;  % this is used to reduce CBF file selection, this can be only a negative integer or 0
     idx=fil(offset+(1:size(files,1)))>0;  % when offset is 0, then this should be equal : idx1=fil

     vo=v(1);
     cmean=mean(dat(:,find(idx==0)),2);   % average all the imgs that ixd==0 (non-marked imgs that isn't over motion) across images
     n_abd=find(idx~=0)';
     tem=num2str(n_abd);
     fprintf('\nThe volumes that have been abandoned to calculate the Mean_corred_CBF*.img are: %s',tem)
    
  %  calculate the new mean of the rest CBF imgs   
     cmean=reshape(cmean,siz(1),siz(2),siz(3));
     [fpath,name,ext,d]=fileparts(files(1,:));
     if length(n_abd)<=5
        vo.fname=fullfile(fpath,['Mean_corred_CBF_', sub_dir_name,'after_abandon_',tem, '.nii']);   % write the Mean_CBF that exclude all the CBF that out of the filter of the motion_parameters
     elseif length(n_abd)>5
        sub_tem=[tem(1) '...total' num2str(length(n_abd))];
        vo.fname=fullfile(fpath,['Mean_corred_CBF_', sub_dir_name,'after_abandon_',sub_tem, '.nii']);   % write the Mean_CBF that exclude all the CBF that out of the filter of the motion_parameters
     end
        vo=spm_write_vol(vo,cmean);
     
     
% it seems non-reasonalbe in the third line below
%              files=spm_select('FPList', sub_dir, '^motion_filtered.*.nii');
%              if size(files,1)<2, fprintf('Not enough images found for %s.\n',sub_dir_name);return;end
%              v=spm_vol(files(find(idx==0),:));   % ???  only half of the ['^fltraw.*.nii'] images were included ?????????
%              dat=spm_read_vols(v);
%              dat=squeeze(mean(dat,4));
%              vo.fname=fullfile(fpath,['Mean_corred_EPI_' sub_dir_name '.nii']);   % write the Mean_BOLD that exclude all the CBF that out of the filter of the motion_parameters
%              vo=spm_write_vol(vo,dat);

fprintf('\n -----------CBF outiler cleaning is done!\n')