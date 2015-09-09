
%  http://faculty.vassar.edu/lowry/rdiff.html
%  http://www.fon.hum.uva.nl/Service/Statistics/Two_Correlations.html
% Characteristics:
%    This is a quite insensitive test to decide whether two correlations have different strengths. In the standard tests for correlation, a correlation coefficient is tested against the hypothesis of no correlation, i.e., R = 0. It is possible to test whether the correlation coefficient is equal to or different from another fixed value, but this has few uses (when can you make a reasonable guess about a correlation coefficient?). However, there are situations where you would like to know whether a certain correlation strength realy is different from another one.
% H0:
%    Both samples of pairs show the same correlation strength, i.e., R1 = R2.

% Assumptions:
%    The values of both members of both samples of pairs are Normal (bivariate) distributed.
%
% Scale:
%    Interval (for the raw data).
%
% Procedure:
%    The two correlation coefficients are transformed with the Fisher Z-transform ( Papoulis):
%
% Zf = 1/2 * ln( (1+R) / (1-R) )

% The difference

% z = (Zf1 - Zf2) / SQRT( 1/(N1-3) + 1/(N2-3) )
%    is approximately Standard Normal distributed.
%    If both the correlation coefficient and the sample size of one of the samples are equal to zero, the standard procedure for correlation coefficients is used on the other values.

% Level of Significance:
%     Use the z value to determine the level of significance.

% Approximation:
%     This is already an approximation which should be used only when both samples (N1 and N2) are larger than 10.

% Remarks:
%     Check whether you realy want to know whether the correlation coefficients are different. Only rarely is this a usefull question.
%     A warning is printed next to the significance level if the number of samples is too small (i.e., less than 11).


function FG_correlation_cofficient_comparison
    clc
    root_dir = spm_select(1,'dir','Select a folder to hold the results...', [],pwd);
      if isempty(root_dir)
        return
      end
      
    cd (root_dir)        
    
    imgs = spm_select(2,'any',['Select two correlation cofficient imgs...'], [],pwd,'.*img$|.*nii$');
          if isempty(imgs)
              return
          end
      [a,b,c,d]=fileparts(deblank(imgs(1,:)));
      [a1,b1,c1,d1]=fileparts(deblank(imgs(2,:)));
      out_name=['pvalue_of-ztest_of_r_between_' b(:,1:8) '_and_' b1(:,1:8) c];
      out_name1=['zvalue_of-ztest_of_r_between_' b(:,1:8) '_and_' b1(:,1:8) c];
      
      
     Vmat1=spm_vol(deblank(imgs(1,:)));% read a piece cbf img
     Vmat2=spm_vol(deblank(imgs(2,:)));% read a piece cbf img
     V1=spm_read_vols(Vmat1);
     V2=spm_read_vols(Vmat2);
     
      V1(find(isnan(V1)))=0; % set the NaN voxels into 0
      V2(find(isnan(V2)))=0; % set the NaN voxels into 0

        
    brain = spm_select(1,'any','Select a whole brain mask[Recomand!],or skip this step~ ', [],pwd,'.*img$|.*nii$');
    if isempty(brain)
        V=spm_vol(deblank(imgs(1,:)));% read a piece cbf img
        dat = spm_read_vols(V);   
        brain_mask=ones(size(dat)); % that means no mask is used
        clear V dat;
     else     
      V_brain = spm_vol(deblank(brain));
      brain_mask = spm_read_vols(V_brain);
    end
     
    Gp_mask=V1.*V2.*brain_mask;
    Gp_mask=logical(Gp_mask); % get the mask across groups.

    
    % specify the num of imgs in each subject's dir
    dlg_prompt={'The case number of 1st group:','The case number of 2nd group: '};
    dlg_name='Cofficient cases number.....';
    dlg_def={'16','16'}; 
   Ans=inputdlg(dlg_prompt,dlg_name,1,dlg_def);  
   N1=str2num(Ans{1});
   N2=str2num(Ans{2});

   pause(0.5)
   
   V=[];
   Z=[];
   fprintf('\n------calculating........')
   V=Gp_mask(:);
   V=double(V);
   Z=V;
   ids=find(Gp_mask==1);
   for i=1:size(ids,1) 
       Zf1=[];Zf2=[];z=[];p=[];
       Zf1 = 1/2 * log( (1+V1(ids(i))) / (1-V1(ids(i))) );
       Zf2 = 1/2 * log( (1+V2(ids(i))) / (1-V2(ids(i))) );
       z = (Zf1 - Zf2) / sqrt( 1/(N1-3) + 1/(N2-3) ); % fisher's z score
% onetailed = 1-normcdf(1.96,0,1);
% could prove susceptible to numerical effects when the term inside the normcdf() function was close to 1. 
%  normcdf(-abs(z),0,1) is a better way to do it.

       p=normcdf(-abs(z),0,1); % z-score to one-tail p-value ;      normcdf(x,mean,std)  the mean and std is the distribution of your data. default is the normal distribution
       if z<0
           p=-p;
       end
       
       V(ids(i))=p;
       Z(ids(i))=z;
   end
   
 fprintf('\n\n--The related parameters of these absolute pvalues(one_tail) are [min,max,median,mean]=[%s, %s, %s, %s]',num2str(min(min(min(abs(V(find(V~=0)))))),'%3f'), num2str(max(max(max(abs(V(find(V~=0)))))),'%3f'),num2str(median(median(median(abs(V(find(V~=0)))))),'%3f'),num2str(mean(mean(mean(abs(V(find(V~=0)))))),'%3f'));
 fprintf('\n--The related parameters of these absolute pvalues(two_tail) are [min,max,median,mean]=[%s, %s, %s, %s]',num2str(2*min(min(min(abs(V(find(V~=0)))))),'%3f'), num2str(2*max(max(max(abs(V(find(V~=0)))))),'%3f'),num2str(2*median(median(median(abs(V(find(V~=0)))))),'%3f'),num2str(2*mean(mean(mean(abs(V(find(V~=0)))))),'%3f'));
  V=reshape(V,size(V1)) ;
  Z=reshape(Z,size(V1)) ;
  
  Vmat1.fname=[root_dir out_name];
  spm_write_vol(Vmat1,V);
%  Vmat1.fname=[root_dir out_name];
%  spm_write_vol(Vmat1,2*V);

  Vmat1.fname=[root_dir out_name1];
  spm_write_vol(Vmat1,Z);
  
  
fprintf('\n\n---Done! \n-------Look for the voxels that its (p)values are between [-0.05 0.05] in the one-tail image!!---\n\n')