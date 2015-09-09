function clean = FG_strip_unwanted(dirty_string)
% just keep the characters belongs to [a-z] [A-Z] [0-9] and [ _ ]
msk = (dirty_string>='a'&dirty_string<='z') | (dirty_string>='A'&dirty_string<='Z') |...
      (dirty_string>='0'&dirty_string<='9') | dirty_string=='_';
clean = dirty_string(msk);
return;