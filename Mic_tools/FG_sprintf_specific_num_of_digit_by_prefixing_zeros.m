function num=FG_sprintf_specific_num_of_digit_by_prefixing_zeros(integer_num,digit_num_after_prefixing_zero)
% integer_num=int6(integer_num);
% digit_num_after_prefixing_zero=int6(digit_num_after_prefixing_zero);
if isnumeric(integer_num) || isnumeric(digit_num_after_prefixing_zero)
    num=sprintf(['%0.' num2str(digit_num_after_prefixing_zero) 'd'],integer_num);  % e.g. sprintf(['%0.3d'],1)  ===>  001
else
    fprintf('     ===Integer number inputs are required!\n')
end

