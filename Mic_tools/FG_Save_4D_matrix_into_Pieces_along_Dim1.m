%separate and save the 4D dataset along the 1st dimension into .mat files	
function [tem_dir,N_pieces]=FG_Save_4D_matrix_into_Pieces_along_Dim1(Vs_4D, file_prefix, min_points_of_Dim1)
%     CBFs=spm_select(inf,'.img|.nii','Select images that you want to deal with ', [],pwd,'.*');
%     [Vs_4D,Vmats]=FG_read_vols(CBFs);
%     Vs_4D=FG_make_sure_NaN_to_zero_img(Vs_4D);
    Dim1=size(Vs_4D,1);
    
    current_dir=pwd;
    tem_dir=fullfile(current_dir,'Temp_FG',filesep);
    mkdir(tem_dir);
    
    if nargin<=2
        min_points_of_Dim1 =4;	% default number to divide the first dimension to "min_points_of_Dim1" pieces
        file_prefix='test_';
    end
    
	N_pieces =floor(Dim1/min_points_of_Dim1);
    
	if N_pieces< (Dim1/min_points_of_Dim1),
		N_pieces =N_pieces +1;
    end
    
	for x = 1:(N_pieces)
		theFilename =fullfile(tem_dir, sprintf('%s%.8d',file_prefix, x));
		if x~=(floor(Dim1/min_points_of_Dim1)+1)
			one_piece_of_Dim1 = Vs_4D(((x-1)*min_points_of_Dim1+1):(x*min_points_of_Dim1), :,:,:);
		else
			one_piece_of_Dim1 = Vs_4D(((x-1)*min_points_of_Dim1+1):end, :,:,:);
		end
		save(theFilename, 'one_piece_of_Dim1'); 		
    end	

    fprintf('\n----- Save %s pieces into files. Done!\n',num2str(N_pieces))
% if nargout~=0
%     varargout={tem_dir};
% end