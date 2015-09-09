
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
%    If both the correlation coefficient and the sample size of one of the samples are equal to zero, 
%    the standard procedure for correlation coefficients is used on the other values.

% Level of Significance:
%     Use the z value to determine the level of significance.

% Approximation:
%     This is already an approximation which should be used only when both samples (N1 and N2) are larger than 10.

% Remarks:
%     Check whether you realy want to know whether the correlation coefficients are different. Only rarely is this a usefull question.
%     A warning is printed next to the significance level if the number of samples is too small (i.e., less than 11).


function FG_correlation_cofficient_comparison_for_vectors
dlg_prompt={'r1                 ','N1                 ','r2                 ','N2                 '};
dlg_name='Enter two r and its df';
dlg_values=inputdlg(dlg_prompt,dlg_name,1,{'0.4','16','0.9','16'},'on');

V1=str2num(dlg_values{1});
V2=str2num(dlg_values{3});
N1=str2num(dlg_values{2});
N2=str2num(dlg_values{4});

       Zf1 = 1/2 * log( (1+V1) / (1-V1) );
       Zf2 = 1/2 * log( (1+V2) / (1-V2) );
       z = (Zf1 - Zf2) / sqrt( 1/(N1-3) + 1/(N2-3) ); % fisher's z score
% onetailed = 1-normcdf(1.96,0,1);
% could prove susceptible to numerical effects when the term inside the normcdf() function was close to 1. 
%  normcdf(-abs(z),0,1) is a better way to do it.

       p=normcdf(-abs(z),0,1); % z-score to one-tail p-value ;      normcdf(x,mean,std)  the mean and std is the distribution of your data. default is the normal distribution
       if z<0
           p=-p;
       end
   
fprintf('\n\n--The z-test of two r is:                   %s\n--The corresponding p-value(one-tail) is:   %s',num2str(z,'%3f'),num2str(p,'%3f'));  
if p>=-0.05 & p<=0.05
    fprintf('\n--The difference between these two r is significant ([-0.05 0.05],one-tail)!---\n')
else
    fprintf('\n\n--The difference between these two r is NOT significant ([-0.05 0.05],one-tail)!---\n')
end