function varargout=FG_read_fun_lists_Grocer
clc
Gfile=which('fmri_grocer');
str_search='| ';
filler_str=sprintf('\n-------------------------------------------------------\n');

h=[];
last_str='';
f_in = fopen(deblank(Gfile));
[PATHSTR,NAME,EXT,VERSN] = fileparts(deblank(Gfile));
new_filename = [pwd, filesep,'The function list of ' ,NAME,'.txt'];
f_out = fopen(new_filename,'w'); % edit test_output.m ===>this may induce a Popout dialogue
i=1;
fun_n=0;
menu_n=0;
while ~feof(f_in) % feof= the end of file
   str = fgets(f_in); % fgetl= read the file line by line; try to compare the difference between [fgetl] and [fgets] here~~~
   a=regexp(str, regexptranslate('escape',str_search), 'once');
   b=regexp(last_str, regexptranslate('escape',str_search), 'once');
   if ~isempty(a) && isempty(b)
      h=strvcat(h,filler_str);
      rep_str1='[num2str(line_n) ''. ';
      rep_str2='''],...';
      rep_str3='''|  ';
      rep_str4=''',...';
      str=regexprep(str, regexptranslate('escape',rep_str3), ' |  ');
      str=regexprep(str, regexptranslate('escape',rep_str4), ' ');
      last_str=regexprep(last_str, regexptranslate('escape',rep_str1), [num2str(i) ' . ']);
      last_str=regexprep(last_str, regexptranslate('escape',rep_str2), '');
      h=strvcat(h,last_str);
      h=strvcat(h,str);
    fprintf(f_out,'%s',filler_str); % be careful: we didn't use [fwrite]   
    fprintf(f_out,'%s',last_str); % be careful: we didn't use [fwrite]   
    fprintf(f_out,'%s',str); % be careful: we didn't use [fwrite]   
    i=i+1;
    menu_n=menu_n+1;
   elseif ~isempty(a) && ~isempty(b)
      rep_str3='''|  ';
      rep_str4=''',...';
      str=regexprep(str, regexptranslate('escape',rep_str3), ' |  ');
      str=regexprep(str, regexptranslate('escape',rep_str4), ' ');
      h=strvcat(h,str);
      fprintf(f_out,'%s',str); % be careful: we didn't use [fwrite]   
      fun_n=fun_n+1;
   end
   last_str=str;
   
end


fclose(f_in);
fclose(f_out);

% fprintf('---- \n%s \n   is created\n',new_filename)
    % delete the created file
    delete(new_filename)

if nargout~=0
    fprintf('---- \nThere are totally %d menus including %d functions...\n\n',menu_n,fun_n)
    varargout={h,f_out};
elseif nargout==0
    h
    fprintf('---- \nThere are totally %d menus including %d functions...\n\n',menu_n,fun_n)
end
