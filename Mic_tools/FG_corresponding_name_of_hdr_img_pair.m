function another_piece=FG_corresponding_name_of_hdr_img_pair(one_piece)
[pth,name,ext,even]=FG_fileparts(one_piece);
if strcmpi(ext,'.hdr')
   another_piece = fullfile(pth,[name '.img']);      
elseif strcmpi(ext,'.img')
   another_piece = fullfile(pth,[name '.hdr']);    
end