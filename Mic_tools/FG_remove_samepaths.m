
function output=FG_remove_samepaths(input)
    if isempty(input), return,  end
    output=spm_str_manip(input,'dc');