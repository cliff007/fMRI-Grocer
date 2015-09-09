function FG_find_and_replaceText_multi_strs
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

    dlg_prompt={'how many strings do you want to search and replace(default is 2):'};
    dlg_name='Num of strings...';
    dlg_def={'2'};
    Ans=inputdlg(dlg_prompt,dlg_name,1,dlg_def);      
 
      if ~strcmp(Ans{1},'0')   
            h=questdlg('Do you have a separate "search str" and "replace str" txt files?','Hi....','Yes','No','Yes') ;
            c_p=which ('FG_example_search_and_replace_str.m');            
           if strcmp('No',h)
                uiwait(msgbox(['I recommend you to get your find and replace m files ready first, and then select "Yes" in the last step to choose your paired m files. Example:' c_p],'Suggestion about the contrasts...','warn','modal'))

                dlg_prompt={};
                dlg_prompt1={};
                dlg_prompt2={};
                for i=1:str2num(Ans{1})
                    dlg_prompt1=[dlg_prompt1,['search',num2str(i),'----------------------------------']];
                    dlg_prompt2=[dlg_prompt2,['search',num2str(i)]];
                end

                dlg_name='Search strs setting';
                search_strs=inputdlg(dlg_prompt1,dlg_name,1,dlg_prompt2);  


                dlg_name='Replace strs setting';
                replace_strs=inputdlg(search_strs',dlg_name,1);  
                
           else
               [a,b,c,d]=fileparts(c_p);
               s_p_file = spm_select(1,'.m','Select the search strs txt file:', [],a,'FG_example_search_and_replace_str*.*m');
              
               [a,b,c,d]=fileparts(s_p_file);
               eval(['[search_strs,replace_strs]=' b,';']);

              h=inputdlg(search_strs,'Search and Replace string pairs, click OK to continue, click cancel to stop',1,replace_strs);  

              if isempty(h)
                  return
              end
           end
      end
       
      
for pair_i=1:size(replace_strs,2)
    str_search =search_strs{pair_i};
    str_replace=replace_strs{pair_i};

if pair_i==1
    for i=1:size(filename,1)
        h=[];
        f_in = fopen(deblank(filename(i,:)));

        [PATHSTR,NAME,EXT,VERSN] = fileparts(deblank(filename(i,:)));
        new_filename = [NAME,'_RepBy_',str_replace,EXT];
        f_out = fopen(new_filename,'w'); % edit test_output.m ===>this may induce a Popout dialogue

        while ~feof(f_in) % feof= the end of file
           str = fgets(f_in); % fgetl= read the file line by line; try to compare the difference between [fgetl] and [fgets] here~~~
           h = [h, regexp(str, regexptranslate('escape',str_search))];
           %fprintf('%s===>',str)   
           str = regexprep(str, regexptranslate('escape',str_search), regexptranslate('escape',str_replace));
           %fprintf('%s\n\n',str)
           fprintf(f_out,'%s',str); % be careful: we didn't use [fwrite]   
        end
           if ~isempty(h)
               fprintf('\nYes! we find and replace ''%s'' with ''%s'' %d times in file\n %s\n',str_search, str_replace, size(h,1),deblank(filename(i,:)))
           else
               fprintf('\nNo! we didn''t find ''%s'' in file\n %s\n',str_search,deblank(filename(i,:)))
           end
        fclose(f_in);
        fclose(f_out);
    end
else
    files=dir(['*_RepBy_*',replace_strs{pair_i-1},EXT]);
       
    for i=1:size(files,1)
        h=[];
        filename=files(i).name;
        f_in = fopen(deblank(filename));

        [PATHSTR,NAME,EXT,VERSN] = fileparts(deblank(filename));
        new_filename = [NAME,'_RepBy_',str_replace,EXT];
        f_out = fopen(new_filename,'w'); % edit test_output.m ===>this may induce a Popout dialogue

        while ~feof(f_in) % feof= the end of file
           str = fgets(f_in); % fgetl= read the file line by line; try to compare the difference between [fgetl] and [fgets] here~~~
           h = [h, regexp(str, regexptranslate('escape',str_search))];
           %fprintf('%s===>',str)   
           str = regexprep(str, regexptranslate('escape',str_search), regexptranslate('escape',str_replace));
           %fprintf('%s\n\n',str)
           fprintf(f_out,'%s',str); % be careful: we didn't use [fwrite]   
        end
           if ~isempty(h)
               fprintf('\nYes! we find and replace ''%s'' with ''%s'' %d times in file\n %s\n',str_search, str_replace, size(h,1),deblank(filename))
           else
               fprintf('\nNo! we didn''t find ''%s'' in file\n %s\n',str_search,deblank(filename))
           end
        fclose(f_in);
        fclose(f_out);
    end
    
    delete (['*_RepBy_*',replace_strs{pair_i-1},EXT]);
    
end
end

      fprintf('\n--------------All are done! The final file is named following by the last replace string you specify!\n\n')



