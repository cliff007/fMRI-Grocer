
function FG_fullfactorial_2nd_gen
% specify the num of factors
prompt = {'Specify the number of factors [ranges 1-3]; (1 for one-way ANOVA)'};
dlg_title = 'Factor nums...';
num_lines = 1;
def = {'1'};
fac_n = inputdlg(prompt,dlg_title,num_lines,def);
fac_n=str2num(fac_n{1});

if fac_n>3 || fac_n<=0
    fprintf('\n----- I can only deal with the number of factors that ranges between 1 and 3 .......\n')
    return
end

% specify levels of factors

    dlg_prompt1={};
    dlg_prompt2={};
    dlg_prompt3={};
    dlg_prompt4={};
    dlg_prompt5={};
    for i=1:fac_n
        dlg_prompt1=[dlg_prompt1;['Name of factor',num2str(i),'--------------------------------------------']];
        dlg_prompt2=[dlg_prompt2;['Factor',num2str(i)]];
        dlg_prompt3=[dlg_prompt3;'2'];
        dlg_prompt4=[dlg_prompt4;'1'];
        dlg_prompt5=[dlg_prompt5;'0'];
    end

    dlg_name='factor names(suggest to enter factors descendly according to their levels)...';
    factor_names=inputdlg(dlg_prompt1,dlg_name,1,dlg_prompt2,'on');  
    if isempty(factor_names), return; end

    dlg_name='Dependence with Factor...';
    factor_names_tem=FG_add_characters_at_the_end(factor_names,'(0:Independt; 1: Dependt) --------------------------------------');
    factor_dependence=inputdlg(factor_names_tem,dlg_name,1,dlg_prompt5,'on'); 
    if isempty(factor_dependence), return; end       
    
    dlg_name='Factor Variance...';    
    factor_names_tem=FG_add_characters_at_the_end(factor_names,'(0:equal; 1: unequal) ---------------------------------------');
    factor_var_dependence=inputdlg(factor_names_tem,dlg_name,1,dlg_prompt4,'on'); 
    if isempty(factor_var_dependence), return; end   
    
    dlg_name='Corresponding levels(suggest to enter descendly)...';
    factor_names_tem=FG_add_characters_at_the_end(factor_names,' ------------------------------------------------------------.');   
    factor_levels=inputdlg(factor_names_tem,dlg_name,1,dlg_prompt3,'on'); 
    if isempty(factor_levels), return; end
    
 all_fac_levels=[];   
 for i=1:fac_n  
     all_fac_levels=[all_fac_levels factor_names{i} '(' factor_levels{i} 'Levels)x'];
 end   
 all_fac_levels= all_fac_levels(1:end-1);  
    
if fac_n==1
    for i=1:fac_n
        if i==1
           subfix_name=factor_levels{i};
        else
           subfix_name=[subfix_name,'x',factor_levels{i}];
        end        

        for j=1:str2num(factor_levels{i})
            imgs_pairs{i,j} = spm_select(inf,'any',sprintf(['Select imgs for level ' num2str(j) ' of all ' all_fac_levels]), [],pwd,'.*img$|.*nii$');
            if isempty(imgs_pairs{i,j}) , return,    end
        end 
    end
elseif fac_n==2
    for i=1:fac_n
        if i==1
           subfix_name=factor_levels{i};
        else
           subfix_name=[subfix_name,'x',factor_levels{i}];
        end     
    end
    for i=1:str2num(factor_levels{1})
        for j=1:str2num(factor_levels{2})
            imgs_pairs{i,j} = spm_select(inf,'any',sprintf(['Select imgs for level ' num2str(i) 'x' num2str(j) ' of all ' all_fac_levels]), [],pwd,'.*img$|.*nii$');
            if isempty(imgs_pairs{i,j}) , return,    end
        end
    end     
elseif fac_n==3
    for i=1:fac_n
        if i==1
           subfix_name=factor_levels{i};
        else
           subfix_name=[subfix_name,'x',factor_levels{i}];
        end     
    end
    for k=1:str2num(factor_levels{3})
        for j=1:str2num(factor_levels{2})
            for i=1:str2num(factor_levels{1})
                imgs_pairs{i,j,k} = spm_select(inf,'any',sprintf(['Select imgs for level '  num2str(i) 'x' num2str(j) 'x' num2str(k) ' of all ' all_fac_levels]), [],pwd,'.*img$|.*nii$');
                if isempty(imgs_pairs{i,j,k}) , return,    end
            end
        end
    end   
end

em = spm_select(1,'any','Select an explicit mask (or you can just close the window if you don''t want this)', [],pwd,'.*img$|.*nii$');
h_global=questdlg('Do you want to do the standard global calibration for CBF analysis?','Hi...','Yes','No','No');

root_dir = FG_module_select_root('Select the directory where to store the estimated files(*.mat/con*.img)');

if strcmp(h_global,'No')    
    write_name=strcat(root_dir,'level2_fullfactorial_', subfix_name, '_noglobal_job.m');
elseif strcmp(h_global,'Yes')  
    write_name=strcat(root_dir,'level2_fullfactorial_', subfix_name, '_global_job.m');
else    
    fprintf('\nYour slection of global calibration is wrong!\n\n')
    return; 
end

    
% build the batch header
dlmwrite(write_name,'%-----------------------------------------------------------------------', 'delimiter', '', 'newline','pc'); 
dlmwrite(write_name, '% Job configuration created by cfg_util (rev $Rev: 3944 $)', '-append', 'delimiter', '', 'newline','pc');
dlmwrite(write_name,'%-----------------------------------------------------------------------', '-append', 'delimiter', '', 'newline','pc'); 
dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.factorial_design.dir = {''',root_dir,'''};'), '-append', 'delimiter', '', 'newline','pc'); 


    if fac_n==1
        dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.factorial_design.des.fd.fact.name = ''',factor_names{1},''';'), '-append', 'delimiter', '', 'newline','pc'); 
        dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.factorial_design.des.fd.fact.levels = ',factor_levels{1},';'), '-append', 'delimiter', '', 'newline','pc'); 
        dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.factorial_design.des.fd.fact.dept = ',factor_dependence{1},';'), '-append', 'delimiter', '', 'newline','pc'); 
        dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.factorial_design.des.fd.fact.variance = ',factor_var_dependence{1},';'), '-append', 'delimiter', '', 'newline','pc'); 
        dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.factorial_design.des.fd.fact.gmsca = 0;'), '-append', 'delimiter', '', 'newline','pc'); 
        dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.factorial_design.des.fd.fact.ancova = 0;'), '-append', 'delimiter', '', 'newline','pc'); 

        for j=1:str2num(factor_levels{1})
            dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(', num2str(j), ').levels = ', num2str(j), ';'), '-append', 'delimiter', '', 'newline','pc'); 
            dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(', num2str(j), ').scans = {'), '-append', 'delimiter', '', 'newline','pc'); 

            for k=1:size(imgs_pairs{i,j},1)
                dlmwrite(write_name,strcat('''',imgs_pairs{i,j}(k,:), ',1'''), '-append', 'delimiter', '', 'newline','pc');
            end
            dlmwrite(write_name,'};', '-append', 'delimiter', '', 'newline','pc'); 
        end
        
    elseif fac_n==2
        for i=1:fac_n
            dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(', num2str(i), ').name = ''',factor_names{i},''';'), '-append', 'delimiter', '', 'newline','pc'); 
            dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(', num2str(i), ').levels = ',factor_levels{i},';'), '-append', 'delimiter', '', 'newline','pc'); 
            dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(', num2str(i), ').dept = ',factor_dependence{i},';'), '-append', 'delimiter', '', 'newline','pc'); 
            dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(', num2str(i), ').variance = ',factor_var_dependence{i},';'), '-append', 'delimiter', '', 'newline','pc'); 
            dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(', num2str(i), ').gmsca = 0;'), '-append', 'delimiter', '', 'newline','pc'); 
            dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(', num2str(i), ').ancova = 0;'), '-append', 'delimiter', '', 'newline','pc'); 
        end
        
        n_cell=1;
        for i=1:str2num(factor_levels{1})
            for j=1:str2num(factor_levels{2})
                
                dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(', num2str(n_cell), ').levels = ', '[', [num2str(i) ' ' num2str(j)], '];'), '-append', 'delimiter', '', 'newline','pc'); 
                dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(', num2str(n_cell), ').scans = {'), '-append', 'delimiter', '', 'newline','pc'); 

                for k=1:size(imgs_pairs{i,j},1)
                    dlmwrite(write_name,strcat('''',imgs_pairs{i,j}(k,:), ',1'''), '-append', 'delimiter', '', 'newline','pc');
                end
                dlmwrite(write_name,'};', '-append', 'delimiter', '', 'newline','pc'); 
                n_cell=n_cell+1;
            end
        end
    elseif fac_n==3
        for i=1:fac_n
            dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(', num2str(i), ').name = ''',factor_names{i},''';'), '-append', 'delimiter', '', 'newline','pc'); 
            dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(', num2str(i), ').levels = ',factor_levels{i},';'), '-append', 'delimiter', '', 'newline','pc'); 
            dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(', num2str(i), ').dept = 0;'), '-append', 'delimiter', '', 'newline','pc'); 
            dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(', num2str(i), ').variance = ',factor_var_dependence{i},';'), '-append', 'delimiter', '', 'newline','pc'); 
            dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(', num2str(i), ').gmsca = 0;'), '-append', 'delimiter', '', 'newline','pc'); 
            dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(', num2str(i), ').ancova = 0;'), '-append', 'delimiter', '', 'newline','pc'); 
        end
        
        n_cell=1;
        for i=1:str2num(factor_levels{1})
            for j=1:str2num(factor_levels{2})
                for k=1:str2num(factor_levels{3})
                
                dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(', num2str(n_cell), ').levels = ', '[', [num2str(i) ' ' num2str(j) ' ' num2str(k)], '];'), '-append', 'delimiter', '', 'newline','pc'); 
                dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(', num2str(n_cell), ').scans = {'), '-append', 'delimiter', '', 'newline','pc'); 

                for l=1:size(imgs_pairs{i,j,k},1)
                    dlmwrite(write_name,strcat('''',imgs_pairs{i,j,k}(l,:), ',1'''), '-append', 'delimiter', '', 'newline','pc');
                end
                dlmwrite(write_name,'};', '-append', 'delimiter', '', 'newline','pc'); 
                n_cell=n_cell+1;
                end
            end
        end
    end

 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.factorial_design.cov = struct(''c'', {}, ''cname'', {}, ''iCFI'', {}, ''iCC'', {});'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.factorial_design.masking.em = {''',em,'''};'), '-append', 'delimiter', '', 'newline','pc');
    
    if strcmp(h_global,'No') 
        dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;'), '-append', 'delimiter', '', 'newline','pc');
        dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;'), '-append', 'delimiter', '', 'newline','pc');
        dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;'), '-append', 'delimiter', '', 'newline','pc');
    elseif strcmp(h_global,'Yes') 
        dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.factorial_design.globalc.g_mean = 1;'), '-append', 'delimiter', '', 'newline','pc');
        dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_yes.gmscv = 50;'), '-append', 'delimiter', '', 'newline','pc');
        dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 2;'), '-append', 'delimiter', '', 'newline','pc');        
    end
    

fprintf('\n-----Check the created job file(.m): %s \n-----Then run the job file in either SPM8 or Grocer!\n',write_name)


