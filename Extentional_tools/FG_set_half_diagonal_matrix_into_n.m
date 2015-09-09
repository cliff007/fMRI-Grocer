function Mat_out=FG_set_half_diagonal_matrix_into_n(Mat,target_val,above_or_below)
% Mat should be a square matrix
if size(Mat,1)~=size(Mat,2)
    fprintf('\n--- input matrix should be a square matrix\n')
    return
elseif size(Mat,1)==1
    Mat_out=Mat;
    return
end

if nargin==1
   target_val=0;
   above_or_below='below';
end

    k=1;
    if strcmpi(above_or_below,'below')       
       for i=1:size(Mat,2)           
           for j=k:size(Mat,1)
                Mat(j,i)=target_val;
           end
           k=k+1;
       end  
    else
       for i=1:size(Mat,1)
           for j=k:size(Mat,2)
                Mat(i,j)=target_val;
           end
           k=k+1;
       end  
    end
    
Mat_out=Mat;