
function output=FG_remove_extentions(input)
    if isempty(input), return,  end
    output=spm_str_manip(input,'dr');