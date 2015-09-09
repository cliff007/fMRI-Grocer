function FG_group_files_into_folders
% this script is used to group files under different groups (e.g. different
% 1st-level conditions) intto different groups with file identifiers (e.g. subject number)
root_dir = FG_module_select_root('Select root folder contain all the group folders');
if any(strcmpi('return',{root_dir})), return; end

[dirs,all_subs_dir]=FG_module_select_groups('Select all group folders under the root folder');
if any(strcmpi('return',{dirs,all_subs_dir})), return; end
 
          
           a=which('FG_file_group_identifier.m');
           [b,c,d,e]=fileparts(a);
           ID_file = spm_select(1,'.m','Select the group identifier txt file(skip this if none):', [],b,'^FG_file_group_identifier*.*m');
           addpath(FG_sep_group_and_path(ID_file));
            
           if strcmp(ID_file,'')
               fprintf('\n---None a identifier file has been selected...\n')
               return               
           else
               [a,b,c,d]=fileparts(ID_file);
               eval(['FG_groups=' b]);
           end

            dlg_prompt={};
            dlg_prompt1={};
            dlg_prompt2={};
            for i=1:size(FG_groups,2)
                dlg_prompt1=[dlg_prompt1,['Group_name',num2str(i),'----------------------------------']];
                if size(FG_groups{i},1)==1
                    dlg_prompt2=[dlg_prompt2,FG_groups{i}];
                elseif size(FG_groups{i},1)>1
                    dlg_prompt2=[dlg_prompt2,['Group',num2str(i)]];
                end
            end

            dlg_name='File identifier setting';
            ID_Ans_name=inputdlg(dlg_prompt1,dlg_name,1,dlg_prompt2,'on');  

        
          
                 
           for j=1:size(dirs,1)
               cd (deblank(all_subs_dir(j,:)))
               
               for i=1:size(FG_groups,2)
                   mkdir (deblank(ID_Ans_name{i,:}));

                   for k=1:size(FG_groups{i},1)
                       try  % use try to deal with the potential error that new created subdirs (group folders) containing the file filter characters 
                        movefile (['*' cell2mat(FG_groups{i}(k)) '*.*'], [deblank(ID_Ans_name{i,:}) filesep]);
                       catch ME1
                           ME1.message
                           continue
                       end
                   end

               end
               
           end





  fprintf('\n----File grouping is done!\n\n')  
    
    