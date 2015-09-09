function datetime_str=FG_get_current_date_str
% clc

datetime_str=datestr(now);
% datetime_str=datestr(clock);
datetime_str=strrep(datetime_str,':','_'); %Replace colon with underscore
datetime_str=strrep(datetime_str,'-','_');%Replace minus sign with underscore
datetime_str=strrep(datetime_str,',','_');%Replace minus sign with underscore
datetime_str=strrep(datetime_str,' ','_');%Replace space with underscore