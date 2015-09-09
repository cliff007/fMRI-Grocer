 %%%%  subfunction, file_rename options~~
function varargout=FG_file_rename_options(all_fileNames,h,h1,Ans)
    if nargin==0 || nargin==1
        if ~exist('all_fileNames','var')
            % select files
             all_fileNames = spm_select(Inf,'.*','Select mutiple files you want to rename', [],pwd,'.*'); 
        end
        if FG_check_ifempty_return(all_fileNames), return;  end 
   
         % separate filenames and filepaths
         fileNames=spm_str_manip(all_fileNames,'dt');  % take use of the "spm_str_manip" function
         filepath=spm_str_manip(all_fileNames,'dh'); 
         filepath=FG_add_filesep_at_the_end(filepath);


        % renaming setup 
          h=questdlg('What do you want to do?','Hi....','Prefix?','Suffix?','Delete characters?','Prefix?') ;    
            if strcmp(h,'Prefix?')
                    h1=questdlg('Which kind of prefix do you want?','Hi....','Strings contain number order? E.g. sub_00,sub_01...999...', ...
                        'Just some specific characters without number?','Strings contain number order? E.g. sub_00,sub_01...999...') ;            
                    if strcmp(h1,'Strings contain number order? E.g. sub_00,sub_01...999...')
                        dlg_prompt={'Enter the fixed string before numbers:'};
                        dlg_name='Prefix string';
                        dlg_def={'Subj'};
                        Ans=inputdlg(dlg_prompt,dlg_name,1,dlg_def);  
                        fprintf('\n--------Renaming...\n\n')     
                    else
                        dlg_prompt={'Enter the string you want to prefix to the original file names:'};
                        dlg_name='Prefix string';
                        dlg_def={'Subj'};
                        Ans=inputdlg(dlg_prompt,dlg_name,1,dlg_def);   
                        fprintf('\n--------Renaming...\n\n')               
                    end        
            elseif strcmp(h,'Suffix?')
                    h1=questdlg('Which kind of Suffix do you want?','Hi....','Strings contain number order? E.g. _end00,_end_01...999...', ...
                        'Just some specific characters without number?','Strings contain number order? E.g. _end00,_end_01...999...') ;            
                    if strcmp(h1,'Strings contain number order? E.g. _end00,_end_01...999...')
                        dlg_prompt={'Enter the string you want to prefix to the original file names:'};
                        dlg_name='Prefix string';
                        dlg_def={'end'};
                        Ans=inputdlg(dlg_prompt,dlg_name,1,dlg_def);  
                         fprintf('\n--------Renaming...\n\n') 
                    else
                        dlg_prompt={'Enter the string you want to subfix to the original file names:'};
                        dlg_name='Suffix string';
                        dlg_def={'end'};
                        Ans=inputdlg(dlg_prompt,dlg_name,1,dlg_def);   
                        fprintf('\n--------Renaming...\n\n') 
                    end        
            elseif strcmp(h,'Delete characters?')
                    h1=questdlg('Which kind of deletion do you want?','Hi....','Delete specific chars...', ...
                        'Delete chars in specific relative positions...','Delete specific chars...') ;
                    if strcmp(h1,'Delete chars in specific relative positions...')
                        dlg_prompt={'Enter the location(digits) of the character(s) you want to delete:'};
                        dlg_name=' Which character(s) to delete, E.g. [1:4 end-3:end])';
                        dlg_def={'1:4 end-3:end'};
                        Ans=inputdlg(dlg_prompt,dlg_name,1,dlg_def);   
                       fprintf('\n--------Renaming...\n\n')    
                    elseif strcmp(h1,'Delete specific chars...')
                        dlg_prompt={'Enter the specific charachers(continuous string) you want to delete:'};
                        dlg_name=' What character(s) to delete, E.g. hello)';
                        dlg_def={'hello'};
                        Ans=inputdlg(dlg_prompt,dlg_name,1,dlg_def);   
                       fprintf('\n--------Renaming...\n\n')   
                    end
            end   
    elseif nargin==4
         if FG_check_ifempty_return(all_fileNames), return;  end 
   
         % separate filenames and filepaths
         fileNames=spm_str_manip(all_fileNames,'dt');  % take use of the "spm_str_manip" function
         filepath=spm_str_manip(all_fileNames,'dh'); 
         filepath=FG_add_filesep_at_the_end(filepath);
    end


 
 
 
 %%% implement renaming
    if strcmp(h,'Prefix?')
            if strcmp(h1,'Strings contain number order? E.g. sub_00,sub_01...999...')  
                for iFile = 1:size(fileNames,1)  %# Loop over the file names
                   tem=deblank(fileNames(iFile,:));
                    if iFile<=9
                      newName = [Ans{1},'0' num2str(iFile) tem];
                  else
                      newName = [Ans{1}, num2str(iFile) tem];
                    end
                  movefile([deblank(filepath(iFile,:)),deblank(fileNames(iFile,:))],[deblank(filepath(iFile,:)),deblank(newName)]);        %# Rename the file
                end    
            else    
                for iFile = 1:size(fileNames,1)  %# Loop over the file names
                   tem=deblank(fileNames(iFile,:));
                   newName = strcat(Ans{1} ,deblank(fileNames(iFile,:)));  %# Make the new name
                   movefile([deblank(filepath(iFile,:)),deblank(fileNames(iFile,:))],[deblank(filepath(iFile,:)),deblank(newName)]);        %# Rename the file
                end
            end        
    elseif strcmp(h,'Suffix?')
             if strcmp(h1,'Strings contain number order? E.g. _end00,_end_01...999...')    
                for iFile = 1:size(fileNames,1)  %# Loop over the file names
                    tem=deblank(fileNames(iFile,:));
                    [a,b,c,d]=fileparts(tem);
                    tem=b;
                    if iFile<=9
                      newName = [tem Ans{1},'0' num2str(iFile) c];
                  else
                      newName = [tem Ans{1} num2str(iFile) c];
                    end
                  movefile([deblank(filepath(iFile,:)),deblank(fileNames(iFile,:))],[deblank(filepath(iFile,:)),deblank(newName)]);        %# Rename the file
                end    
            else  
                for iFile = 1:size(fileNames,1)  %# Loop over the file names
                   tem=deblank(fileNames(iFile,:));
                    [a,b,c,d]=fileparts(tem);
                    tem=b;
                   newName = strcat(tem, Ans{1}, c);  %# Make the new name
                   movefile([deblank(filepath(iFile,:)),deblank(fileNames(iFile,:))],[deblank(filepath(iFile,:)),deblank(newName)]);        %# Rename the file
                end  
            end        
    elseif strcmp(h,'Delete characters?')
             if strcmp(h1,'Delete chars in specific relative positions...')   
                for iFile = 1:size(fileNames,1)  %# Loop over the file names
                   tem=deblank(fileNames(iFile,:));
                   [a,b,c,d]=fileparts(tem);
                   tem=b;  %% get the file name without filename extension
                   i_tem=[1:length(tem)];
                   % excellent idea~~~~~~~~~
                   deleted_chars_pos = eval(['i_tem([' Ans{1} '])']); % get the position of the requested chars
                   newName = [tem(i_tem(~ismember(i_tem,deleted_chars_pos))), c]; % get the left position of the original name, and get the new name               
                   movefile([deblank(filepath(iFile,:)),deblank(fileNames(iFile,:))],[deblank(filepath(iFile,:)),deblank(newName)]);        %# Rename the file
                end    
            elseif strcmp(h1,'Delete specific chars...')   
                for iFile = 1:size(fileNames,1)  %# Loop over the file names
                   tem=deblank(fileNames(iFile,:));
                   [a,b,c,d]=fileparts(tem);
                   tem=b;  %% get the file name without filename extension
                   first_deleted_pos=regexp(tem,Ans{1});
                   all__deleted_chars_pos=[];
                   if ~isempty(first_deleted_pos)
                       for j=1:length(first_deleted_pos)
                           all__deleted_chars_pos=[all__deleted_chars_pos,first_deleted_pos(j):first_deleted_pos(j)+length(Ans{1})-1];
                       end
                       % excellent idea~~~~~~~~~
                       tem(all__deleted_chars_pos)=[];
                       newName = [tem, c]; % get the left position of the original name, and get the new name               
                       movefile([deblank(filepath(iFile,:)),deblank(fileNames(iFile,:))],[deblank(filepath(iFile,:)),deblank(newName)]);        %# Rename the file
                   end
                end
            end
    end
    
    if nargout==3
        varargout(1)={h};
        varargout(2)={h1};
        varargout(3)={Ans};
    end
    
 fprintf('\n------All set...\n\n')  