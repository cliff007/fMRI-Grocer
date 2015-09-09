
function output=FG_remove_paths(input)
    if isempty(input), return,  end
    output=spm_str_manip(input,'dt');