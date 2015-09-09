function FG_category_all_Cons_in_1stLevel
% root_dir = FG_module_select_root;
% 
% groups = FG_module_select_groups;

anyreturn=FG_modules_selection('Select the root folder of a group of subjects''s first level results','Please select the subject folders under a group','','^','r','g');
if anyreturn, return;end

    dlg_prompt={'How many Contrast img for each subject(if you have [T & F_names_contrasts.m] files, you don''t need to setup this )'};
    dlg_name='Contrast img folders';
    dlg_def={'2'};
    Ans=inputdlg(dlg_prompt,dlg_name,1,dlg_def,'on');   
 
       h=questdlg('Do you have a [T & F_names_contrasts.m] files which you used in generating all T/F-Contrasts?','Hi....','Yes','No','Yes') ;
      
             
       mkdir ('Cons_imgs_of_1st_Level');
       
       if strcmp('No',h)
            dlg_prompt={};
            dlg_prompt1={};
            dlg_prompt2={};
            for i=1:str2num(Ans{1})
                dlg_prompt1=[dlg_prompt1,['Con_',num2str(i),'.hdr/img name----------------------------------']];
                dlg_prompt2=[dlg_prompt2,['Con_',num2str(i)]];
            end

            dlg_name='Contrast image names setting';
            Con_Ans_name=inputdlg(dlg_prompt1,dlg_name,1,dlg_prompt2);  
            
            
            for i=1:size(Con_Ans_name,1)
                mkdir (['Cons_imgs_of_1st_Level' filesep Con_Ans_name{i,:}]);
            end


            for j=1:size(Con_Ans_name,1)
                for i=1:size(groups,1)   
                    try                         
                        if j<=9
                        copyfile ([groups(i,:),filesep,'con_000',num2str(j),'.hdr'],['Cons_imgs_of_1st_Level',filesep, Con_Ans_name{j,:},filesep,'con_000',num2str(j),'_',groups(i,:),'.hdr']);
                        copyfile ([groups(i,:),filesep,'con_000',num2str(j),'.img'],['Cons_imgs_of_1st_Level',filesep, Con_Ans_name{j,:},filesep,'con_000',num2str(j),'_',groups(i,:),'.img']);
                        else
                        copyfile ([groups(i,:),filesep,'con_00',num2str(j),'.hdr'],['Cons_imgs_of_1st_Level',filesep, Con_Ans_name{j,:},filesep,'con_000',num2str(j),'_',groups(i,:),'.hdr']);
                        copyfile ([groups(i,:),filesep,'con_00',num2str(j),'.img'],['Cons_imgs_of_1st_Level',filesep, Con_Ans_name{j,:},filesep,'con_000',num2str(j),'_',groups(i,:),'.img']);
                        end
                    catch me
                        me.message
                        continue
                    end
                end
            end 
       else
           
           a=which('FG_T_names_contrasts.m');
           [b,c,d,e]=fileparts(a);
           T_file = spm_select(1,'.m','Select the T-contrast names txt file(skip this if none):', [],b,'^FG_T*_name.*m');
           F_file = spm_select(1,'.m','Select the F-contrast names txt file(skip this if none):', [],b,'^FG_F*_name.*m');
           if ~isempty(T_file)
               addpath(FG_sep_group_and_path(T_file));
           end
           if ~isempty(F_file)
               addpath(FG_sep_group_and_path(F_file));
           end
           if ~strcmp(T_file,'')
               [a,b,c,d]=fileparts(T_file);
               eval(['[T_1,T_2]=' b]);
           else
               T_1={};
           end
       
           
           if ~strcmp(F_file,'')
               [a,b,c,d]=fileparts(F_file);
               eval(['[F_1,F_2]=' b]); 
           else
               F_1={};
           end
           
           all_cons_names=[T_1 F_1];
            
            dlg_prompt={};
            dlg_prompt1={};
            for i=1:size(all_cons_names,2)
                dlg_prompt1=[dlg_prompt1,['Con_',num2str(i),'.hdr/img name----------------------------------']];
            end
            dlg_name='Contrast names';
            
            
            if size(all_cons_names,2)>12
                Con_Ans_name_1=inputdlg(dlg_prompt1(1:floor(size(all_cons_names,2)/2)),dlg_name,1,all_cons_names(1:floor(size(all_cons_names,2)/2))); 
                Con_Ans_name_2=inputdlg(dlg_prompt1(floor(size(all_cons_names,2)/2)+1:end),dlg_name,1,all_cons_names(floor(size(all_cons_names,2)/2)+1:end)); 
                Con_Ans_name=[Con_Ans_name_1;Con_Ans_name_2];
            else
                Con_Ans_name=inputdlg(dlg_prompt1,dlg_name,1,all_cons_names);
            end
       
       
           
            for i=1:size(Con_Ans_name,1)
                mkdir (['Cons_imgs_of_1st_Level' filesep Con_Ans_name{i,:}]);
            end


            for j=1:size(Con_Ans_name,1)
                for i=1:size(groups,1)  
                    try
                        if j<=9
                        copyfile ([deblank(groups(i,:)),filesep,'con_000',num2str(j),'.hdr'],['Cons_imgs_of_1st_Level',filesep, Con_Ans_name{j,:},filesep,'con_000',num2str(j),'_',deblank(groups(i,:)),'.hdr']);
                        copyfile ([deblank(groups(i,:)),filesep,'con_000',num2str(j),'.img'],['Cons_imgs_of_1st_Level',filesep, Con_Ans_name{j,:},filesep,'con_000',num2str(j),'_',deblank(groups(i,:)),'.img']);
                        else
                        copyfile ([deblank(groups(i,:)),filesep,'con_00',num2str(j),'.hdr'],['Cons_imgs_of_1st_Level',filesep, Con_Ans_name{j,:},filesep,'con_000',num2str(j),'_',deblank(groups(i,:)),'.hdr']);
                        copyfile ([deblank(groups(i,:)),filesep,'con_00',num2str(j),'.img'],['Cons_imgs_of_1st_Level',filesep, Con_Ans_name{j,:},filesep,'con_000',num2str(j),'_',deblank(groups(i,:)),'.img']);
                        end
                    catch me
                        me.message
                        continue
                    end
                end
            end
            

       end

  fprintf('\n------------All set!\n\n')  
    
    