function FG_show_correlation_matrix(Mat)
var_name=inputname(1);
figure('name',['Matrix of ' var_name]);
if min(Mat(:))<max(Mat(:))
    clims=[min(Mat(:)),max(Mat(:))];
else
    clims=[min(Mat(:)),2*max(Mat(:))];  
end
imagesc(Mat,clims),
colormap(hot)
colorbar;
