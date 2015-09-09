%Load a piece of 4D dataset from files, return a 4D-Matrix 
function Result=FG_Load_4D_Pieces_of_Dim1(tem_dir,file_prefix,piece_N)	
    filename =fullfile(tem_dir, sprintf([file_prefix '%.8d'], piece_N));
	Result =load(filename);
	theFieldnames=fieldnames(Result);	
	Result = Result.(theFieldnames{1});
    
    fprintf('\n----- read the piece %s into memory. Done!\n',num2str(piece_N))
