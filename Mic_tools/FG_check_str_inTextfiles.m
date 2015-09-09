function FG_check_str_inTextfiles
clc  

root_dir = spm_select(1,'dir','Select the root folder', [],pwd);
   if isempty(root_dir)
      return
   end 
cd (root_dir)
filename = spm_select(inf,'.m|.txt','Select the txt files you want to deal with', [],pwd,'.*');
    if isempty(filename)
      return
   end 

prompt={'Enter the string you want to search(Use "\" to deal with the special characters):'};
name='search and check...';
numlines=1; 
Ans=inputdlg(prompt,name,numlines);
str_search =Ans{1};


fprintf('\nOnly report the files that have requested characters............................\n\n')
fprintf('-------Hit''%s''-------\n\n',str_search)

j=0;
for i=1:size(filename,1)
    h=[];
    f_in = fopen(deblank(filename(i,:)));
    while ~feof(f_in) % feof= the end of file
       str = fgets(f_in); % fgetl= read the file line by line; try to compare the difference between [fgetl] and [fgets] here~~~
       %fprintf('%s===>',str); 
       h = [h, regexp(str, regexptranslate('escape',str_search))];
    end
    
       if ~isempty(h)
           j=j+1;
%           fprintf('\nYes! we find ''%s'' %d times in file\n %s\n',str_search, size(h,1),deblank(filename(i,:)))
           fprintf('%d. %d times in:    %s\n',j, size(h,1),deblank(filename(i,:)))
%        else
%            fprintf('\nNo! we didn''t find ''%s'' in file\n %s\n',str_search,deblank(filename(i,:)))
       end       
    fclose(f_in);
end

fprintf('\n\n----------------done------------\n')


