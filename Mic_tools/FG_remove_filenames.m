
function output=FG_remove_filenames(input)
    if isempty(input), return,  end
    output=spm_str_manip(input,'dh');