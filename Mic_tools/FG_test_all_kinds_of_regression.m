function FG_test_all_kinds_of_regression
%%%%%%%%%%%%%%%%%%%  1111111111111111      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         Matlab提供了两种除法运算：左除（\）和右除（/）。
%         一般情况下，x=a\b是方程a*x =b的解，而x=b/a是方程x*a=b的解。
%         例：a=[1  2  3; 4  2  6;7  4  9]
%         b=[4; 1; 2];
%         x=a\b
%         则显示：x=
%                   -1.5000
%                    2.0000
%                    0.5000
%         如果a为非奇异矩阵，则a\b和b/a可通过a的逆矩阵与b阵得到：
%                a\b = inv(a)*b
%                b/a = b*inv(a)
% 
% 
%         从线性代数的角度看,其实这些东西跟线性代数的东西是基本对应的，
%         比如说 A*x=b
%         如果从线性代数的角度 我们知 x=A逆 *  b
%         我们可以理解   逆*  就是   除法  分子当然是b了，所以就是左除（\） 了
%         其是也可以直接这样理解     算出 A逆  然后再 *b,  殊途同归
%         A逆 可以视为   A的  -1 次幂  结果都一样。
%%%%%%%%%%%%%%%%%%%  2222222222222222      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                         问：
%                         matlab用逆矩阵和左除方法求解:
% 
%                         方程组AX=b,并对结果进行比较
%                         其中A=rand(500),x为500维全1的向量
%                         b=A*X,写出程序指令,并比较计算精度和计算时间。
% 
%                         答：
%                         A=rand(500);
%                         b=ones(500,1);
%                         tic
%                         x=inv(A)*b;
%                         toc
%                         max(A*x-b)
%                         tic
%                         x=A\b;
%                         toc
%                         max(A*x-b)
% 
%                         结果表明：左除的精度更高，时间更短
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 参考《回归 矩阵 matlab.pdf》文件里的说明
    %% 如：Y=a1 + a2*x + a3*x^2 + e
    %% 1. Y= X*A, To get A;  Y:(m,1), X:(m,n), A:(n,1),
    %% 基于最小二乘法，在已知一组Y和X值的情况下，回归系数A的估计值是 inv(X'*X)*(X'*Y) = (X'*X)\(X'*Y)
    %% 因此，残差为：Y - X*inv(X'*X)*(X'*Y) = (E-X*inv(X'*X)*X')*Y = (E-X/(X'*X)*X')*Y 
    %% 因此，残差也为：Y - X*inv(X'*X)*（X'*Y）= Y - X*((X'*X)\(X'*Y))
Y=[71.7
   13.3
   44.5%];
   55.6];

X=[ 3.3    5.4   35.6
   27.9   47.8   23.9
   14.1    7.1   35.4%];
   19.1    9.1   33.4];

% below are two equal soluation for getting X
%     A=inv(X)*Y
    A1=X\Y    
    A2=inv(X'*X)*X'*Y
    %%% be careful:  X:(m,n), if m ~= n, then you can only use X\Y or inv(X'*X)*X'*Y (rather than inv(X)*Y) to get A
    fprintf('\n-------1. done...')

    
%% 2. Y= X*A, To get Residual
% Residual=Y-A*X
E=eye(size(Y, 1)) ;
Resd=(E-X*inv(X'*X)*X')*Y
Resd1=(E-X/(X'*X)*X')*Y
resd2=Y - X*((X'*X)\(X'*Y))


% Ybar=Abar*X;
% Resd=Y-Ybar;
% Resd=Y-Abar*X;
% Resd=Y-Y/X*X;
% Resd=Y(1-inv(X*X));
fprintf('\n-------2. done...')

%% 3. Y= X*A, Use "regress" To get A and Residual
[A,Aint,Residuals] = regress(Y,X);
A,Residuals
fprintf('\n-------3. done...')

%% 4. Y, X, compare "regress" and "corrcoef"
Y=[71.7
   13.3
   44.5
   55.6];

X=[ 3.3
   27.9
   14.1
   19.1];

[A] = regress(Y,X)

[A1] = regress(zscore(Y),zscore(X)) % 对于一元回归，标准分的回归系数等于相关系数

[A_tem] = corrcoef(Y,X);
A2=A_tem(1,2)

fprintf('\n-------4. done...')

%% 5. Y, X, compare "regress" with constant item and "polyfit(x,y,1)"
constant_vec=ones(length(Y),1);
[A11] = regress(Y,[X constant_vec])
% [A111] = regress(Y,[constant_vec X])
poly_r=polyfit(X,Y,1) 

[A12] = regress(zscore(Y),[zscore(X) constant_vec])
poly_r=polyfit(zscore(X),zscore(Y),1) 

fprintf('\n-------5. done...')

%% 6. Covariates_polort
Covariates_polort=2;
if Covariates_polort>=0,
    thePolOrt =(1:size(X,1))';
    thePolOrt =repmat(thePolOrt, [1, (1+Covariates_polort)]);
    for x=1:(Covariates_polort+1),
        thePolOrt(:, x) =thePolOrt(:, x).^(x-1) ;
    end
end
Covariates =[X,thePolOrt];
[A111] = regress(Y,Covariates)

fprintf('\n-------6. done...\n')

%% 7. Y, X, get multiple linear regression coefficient with  "regress"  and " inv(X'*X)*(X'*Y)"
Y=[71.7
   13.3
   44.5;
   55.6];

X=[ 3.3    5.4   35.6
   27.9   47.8   23.9
   14.1    7.1   35.4;
   19.1    9.1   33.4];

constant_vec=ones(length(Y),1);
[A1] = regress(Y,[X constant_vec])
tem=[X constant_vec];
A2=inv(tem'*tem)*tem'*Y
fprintf('\n-------6. done...\n')

%% 8. "stepwise" multiple linear regression 
[B,SE,PVAL,in,stats,nextstep,history] = stepwisefit(X,Y) 
    % Note: stepwisefit automatically includes a constant term in all models. Do not enter a column of 1s directly into 
fprintf('\n-------8. done...\n')

%% 9. compare "partialcorr" and "regress" and manual calculation in multiple linear regression 
[A1] = regress(Y,[X constant_vec])
[A11] = partialcorr(X,Y)
fprintf('\n-------9. done...\n')


%% 10. test "partialcorr" and manually calculating partial correlation coefficient
% [A1] = regress(X,Y);

fprintf('\n-------10. done...\n')
%% manually calculate correlation coefficient of Y and each column of X
    %% r(x,y)=(X-Xmean)(Y-Ymean)/((n-1)*XSTD*YSTD)
    %% r(x,y)=zscore(x)*zscore(y)/(n-1),
Y=[11.7
   13.3
   14.5;
   15.6];

X=[ 3.3    5.4   35.6
   27.9   47.8   23.9
   14.1    7.1   35.4;
   19.1    9.1   33.4];

Y_zscore=zscore(Y,0,1);
    % OR
    Y_mean=mean(Y);
    Y_std=std(Y);
    Y_zscore1=(Y-Y_mean)/Y_std;
    Y_std1=std(Y-Y_mean); %  std before and after removing the mean is the same
Y_zscore-Y_zscore1

X_zscore=zscore(X,0,1);
    % OR
    X_mean=mean(X,1);
    X_std=std(X,0,1);
    X_zscore1=(X-repmat(X_mean,size(X,1),1))./repmat(X_std,size(X,1),1);
X_zscore-X_zscore1

r=(Y_zscore'*X_zscore)/(size(X,1)-1)
    % OR
    r1=corrcoef([Y X]);
    r1=r1(1,2:end)
    
 r3_molecule=(Y-Y_mean)'* (X-repmat(X_mean,size(X,1),1));
 r3_denominator=((size(X,1)-1)*Y_std*X_std);
 r3=   r3_molecule./r3_denominator
 
 H(:,:,1)=X; H(:,:,2)=X/0.3;
 H_mean=mean(H,3)   ;
fprintf('\n-------11. done...\n')
