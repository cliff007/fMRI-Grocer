function FG_find_and_replaceText
clc  

root_dir = spm_select(1,'dir','Select the root folder of the files you want to deal with', [],pwd);
   if isempty(root_dir)
      return
   end 
cd (root_dir)
filename = spm_select(inf,'.m|.txt','Select the txt files you want to deal with', [],pwd,'.*');
    if isempty(filename)
      return
   end 

prompt={'Enter the string you want to search(Use "\" to deal with the special characters):','Enter the string you want to replace with(Use "\" to deal with the special characters):'};
name='search and replace...';
numlines=1; 
Ans=inputdlg(prompt,name,numlines);
str_search =Ans{1};
str_replace=Ans{2};


fprintf('\nOnly report the files that have requested characters............................\n\n')
fprintf('-------Hit ''%s'' and replace it with ''%s''-------\n\n',str_search, str_replace)
j=0;
for i=1:size(filename,1)
    h=[];
    f_in = fopen(deblank(filename(i,:)));
    
    [PATHSTR,NAME,EXT,VERSN] = fileparts(deblank(filename(i,:)));
    str_replace_name=regexprep(str_replace, regexptranslate('escape',':\'),'_');
    new_filename = [PATHSTR, filesep, NAME,'_replaced_by_',str_replace_name,EXT];
    f_out = fopen(new_filename,'w'); % edit test_output.m ===>this may induce a Popout dialogue
  
    while ~feof(f_in) % feof= the end of file
       str = fgets(f_in); % fgetl= read the file line by line; try to compare the difference between [fgetl] and [fgets] here~~~
       h = [h, regexp(str, regexptranslate('escape',str_search))];
       %fprintf('%s===>',str)   
       str = regexprep(str, regexptranslate('escape',str_search), regexptranslate('escape',str_replace));
       %fprintf('%s\n\n',str)
       fprintf(f_out,'%s',str); % be careful: we didn't use [fwrite]   
    end
    
    
    fclose(f_in);
    fclose(f_out); 
    
       if ~isempty(h)
           j=j+1;
%           fprintf('\nYes! we find and replace ''%s'' with ''%s'' %d times in file\n %s\n',str_search, str_replace, size(h,1),deblank(filename(i,:)))
           fprintf('%d.  %d times in:    %s\n', j, size(h,1),deblank(filename(i,:)))
       else
            delete(new_filename) % in this case delete the tem file created
%            fprintf('\nNo! we didn''t find ''%s'' in file\n %s\n',str_search,deblank(filename(i,:)))
       end

end

fprintf('\n\n----------------done------------\n')


