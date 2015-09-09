function FG_contrast_all_T_F_gen
 
    dirs = spm_select(inf,'dir','Select all output folders containing SPM.mat files', [],pwd,'.*'); 
    
    DelorNo = questdlg('Do you want to delete the existing contrasts after you create the new contrasts?','Delete or not...','Del','No','Del') ;
    if strcmp(DelorNo,'Del')
        DelorNo=1;
    elseif strcmp(DelorNo,'No')
        DelorNo=0;
    end
    
  
    dlg_prompt={'How many T-contrasts do you want to create(default is 2):','How many F-contrasts do you want to create:','How many rows of the F-contrast(at most 2 factors:(n-1)*(m-1)):'};
    dlg_name='(If you have [T & F_names_contrasts.m] files, you can ignore this )';
    dlg_def={'2', '0', '2'};
    Ans=inputdlg(dlg_prompt,dlg_name,1,dlg_def,'on');   
    
    if ~strcmp(Ans{1},'0')   
       h=questdlg('Do you have a [T_names_contrasts.m] files where each T-contrast names and numbers are stored in a two variables separately?','Hi....','Yes','No','Yes') ;
       a=which ('FG_T_names_contrasts.m');
       [c_p,b,c,d]=fileparts(a);
      
       if strcmp('No',h)
%         uiwait(msgbox(['Next time I recommend you to use [-- Edit T_contrasts template]  memu to get your contrast file ready first, and then select "Yes" in the last step to choose your contrast file. The contrast file is here: ' c_p ],'Suggestion about the contrasts...','warn','modal'))
            dlg_prompt1={};
            dlg_prompt2={};
            dlg_prompt3={};
            for i=1:str2num(Ans{1})
                dlg_prompt1=[dlg_prompt1,['T',num2str(i),'----------------------------------']];
                dlg_prompt2=[dlg_prompt2,['T',num2str(i)]];
                dlg_prompt3=[dlg_prompt3,'1'];
            end

            dlg_name='T-contrasts names setting';
            T_Ans_name=inputdlg(dlg_prompt1,dlg_name,1,dlg_prompt2,'on');  

        
            dlg_name='T-contrasts setting';
            T_Ans=inputdlg(T_Ans_name',dlg_name,1,dlg_prompt3,'on');  
       else
          T_file = spm_select(1,'.m','Select the T-contrast names file:', [],c_p,'^FG_T*_name.*m');
          addpath(FG_sep_group_and_path(T_file));
          [a,b,c,d]=fileparts(deblank(T_file));
           eval(['[T_1,T_2]=' b]);
           
          T_Ans_name=T_1;  
          T_Ans=inputdlg(T_1,'T-contrasts, click OK to continue, click cancel to stop',1,T_2);  
          
          if isempty(T_Ans)
              return
          end

       end
       
    elseif strcmp(Ans{1},'0') 
        T_Ans=[]; % just to set up a number for the following parameters (i.e. size(T_Ans,1))
    end
    
    
    if ~strcmp(Ans{2},'0')
        
        h=questdlg('Do you have a [F_names_contrasts.m] files where each F-contrast names and numbers are stored in a two variables separately?','Hi....','Yes','No','Yes') ;

        if strcmp('No',h)
            a=which ('FG_F_names_contrasts.m');
            [c_p,b,c,d]=fileparts(a);
            
%             uiwait(msgbox(['Next time I recommend you to use [-- Edit F_contrasts template]  memu to get your contrast file ready first, and then select "Yes" in the last step to choose your contrast file. The contrast file is here: ' c_p ],'Suggestion about the contrasts...','warn','modal'))
            dlg_prompt1={};
            dlg_prompt2={};     
            dlg_prompt3={};
            for i=1:str2num(Ans{2})
                dlg_prompt1=[dlg_prompt1,['F',num2str(i),'----------------------------------']];
                dlg_prompt2=[dlg_prompt2,['F',num2str(i)]];
                dlg_prompt3=[dlg_prompt3,'1 -1'];
            end

            dlg_name='F-contrasts names setting';
            F_Ans_name=inputdlg(dlg_prompt1,dlg_name,1,dlg_prompt2,'on'); 

            dlg_name='F-contrasts setting';
            F_Ans=inputdlg(F_Ans_name',dlg_name,str2num(Ans{3}),dlg_prompt3,'on');  
        
        else
            F_file = spm_select(1,'.m','Select the F-contrast names file:', [],c_p,'^FG_F*_name.*m');
            addpath(FG_sep_group_and_path(F_file));
            [a,b,c,d]=fileparts(F_file);
            eval(['[F_1,F_2]=' b]);
            
            F_Ans_name=F_1;
            F_Ans=inputdlg(F_1,'F-contrasts, click OK to continue, click cancel to stop',1,F_2);  
            
            if isempty(F_Ans)
               return
            end    
        end
        
    elseif strcmp(Ans{2},'0') 
        F_Ans=[]; % just to set up a number for the following parameters (i.e. size(F_Ans,1))        
    end
        
    
write_name=['contrast_all_'  num2str(size(dirs,1)) 'job.m'];   

    % build the batch header
    dlmwrite(write_name,'%-----------------------------------------------------------------------', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name, '% Job configuration created by cfg_util (rev $Rev: 3944 $)', '-append', 'delimiter', '', 'newline','pc');
    dlmwrite(write_name,'%-----------------------------------------------------------------------', '-append', 'delimiter', '', 'newline','pc'); 
    
for j=1:size(dirs,1)

    tem=deblank(dirs(j,:));
    tem=tem(1:end-1);
    P = spm_select('FPList',tem ,'SPM.mat$');

    
    dlmwrite(write_name,strcat('matlabbatch{', num2str(j), '}.spm.stats.con.spmmat = {'), '-append', 'delimiter', '', 'newline','pc');     
    dlmwrite(write_name,['''' P ''''], '-append', 'delimiter', '', 'newline','pc');
    dlmwrite(write_name,'};', '-append', 'delimiter', '', 'newline','pc');
    
    i_f=1; % undeletable for the conditon that no T-contrasts
    if ~strcmp(Ans{1},'0')
        for i=1:size(T_Ans,1)
            dlmwrite(write_name,strcat('matlabbatch{', num2str(j), '}.spm.stats.con.consess{', num2str(i), '}.tcon.name =''',  T_Ans_name{i},''';'), '-append', 'delimiter', '', 'newline','pc'); 
            dlmwrite(write_name,strcat('matlabbatch{', num2str(j), '}.spm.stats.con.consess{', num2str(i), '}.tcon.convec =[', T_Ans{i},'];'), '-append', 'delimiter', '', 'newline','pc'); 
            dlmwrite(write_name,strcat('matlabbatch{', num2str(j), '}.spm.stats.con.consess{', num2str(i), '}.tcon.sessrep = ''none'';'), '-append', 'delimiter', '', 'newline','pc'); 
        end
       i_f=i+1; 
    end
    
    tem_f=0;
    if ~strcmp(Ans{2},'0')
        for i=i_f:(size(T_Ans,1)+size(F_Ans,1))
            tem_f=tem_f+1;
            dlmwrite(write_name,strcat('matlabbatch{', num2str(j), '}.spm.stats.con.consess{', num2str(i), '}.fcon.name = ''',  F_Ans_name{tem_f},''';'), '-append', 'delimiter', '', 'newline','pc'); 
            dlmwrite(write_name,strcat('matlabbatch{', num2str(j), '}.spm.stats.con.consess{', num2str(i), '}.fcon.convec = {['), '-append', 'delimiter', '', 'newline','pc'); 
           % dlmwrite(write_name,'[', '-append', 'delimiter', '', 'newline','pc'); 
            for t=1:size(F_Ans{tem_f},1)
                dlmwrite(write_name,F_Ans{tem_f}(t,:), '-append', 'delimiter', '', 'newline','pc'); 
            end
            
           % dlmwrite(write_name,']', '-append', 'delimiter', '', 'newline','pc'); 
            dlmwrite(write_name,']}'';', '-append', 'delimiter', '', 'newline','pc'); 
            dlmwrite(write_name,strcat('matlabbatch{', num2str(j), '}.spm.stats.con.consess{', num2str(i), '}.fcon.sessrep = ''none'';'), '-append', 'delimiter', '', 'newline','pc');        
        end            
    end
    
    dlmwrite(write_name,strcat('matlabbatch{', num2str(j), '}.spm.stats.con.delete = ', num2str(DelorNo), ';'), '-append', 'delimiter', '', 'newline','pc');

end

fprintf('\n-----Check the created job file(.m): %s \n-----Then run the job file in either SPM8 or Grocer!\n',write_name)