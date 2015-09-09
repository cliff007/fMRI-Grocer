% recombine the pieces of 4D-Vs into a big 4D-matrix
function Vs_4D=FG_combine_4D_Pieces_of_Dim1_into_big4D(tem_dir, file_prefix, min_points_of_Dim1, Dim1)	
    
    Vs=FG_Load_4D_Pieces_of_Dim1(tem_dir,file_prefix,1)	;
    Dim2=size(Vs,2);Dim3=size(Vs,3);Dim4=size(Vs,4);
    
    Vs_4D=single(zeros(Dim1, Dim2, Dim3));
    Vs_4D =repmat(Vs_4D, [1,1,1, Dim4]);
       
        
	N_pieces =floor(Dim1/min_points_of_Dim1);
    
	if N_pieces< (Dim1/min_points_of_Dim1),
		N_pieces =N_pieces +1;
    end
    
	for x=1:(N_pieces)
				
% 		theFilename =fullfile(tem_dir, sprintf([file_prefix '%.8d'], x));
		%fprintf('\t%d',x);% Just for debugging
		if x~=(floor(Dim1/min_points_of_Dim1)+1)
			Vs_4D(((x-1)*min_points_of_Dim1+1):(x*min_points_of_Dim1),:,:,:)=single(FG_Load_4D_Pieces_of_Dim1(tem_dir,file_prefix,x));
		else
			Vs_4D(((x-1)*min_points_of_Dim1+1):end,:,:,:)=single(FG_Load_4D_Pieces_of_Dim1(tem_dir,file_prefix,x));
        end
    end
        Vs_4D=double(Vs_4D);
        fprintf('\n----- pieces combination is done!')
