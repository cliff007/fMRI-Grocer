function FG_result_all_gen

    dirs = spm_select(inf,'dir','Select all output folders containing SPM.mat files', [],pwd,'.*'); 

    write_name=['result_all_'  num2str(size(dirs,1)) 'job.m'];   

    % build the batch header
    dlmwrite(write_name,'%-----------------------------------------------------------------------', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name, '% Job configuration created by cfg_util (rev $Rev: 3944 $)', '-append', 'delimiter', '', 'newline','pc');
    dlmwrite(write_name,'%-----------------------------------------------------------------------', '-append', 'delimiter', '', 'newline','pc'); 
    
for j=1:size(dirs,1)
    
    tem=deblank(dirs(j,:));
    tem=tem(1:end-1);
    P = spm_select('FPList',tem ,'SPM.mat$');

    
    dlmwrite(write_name,strcat('matlabbatch{', num2str(j), '}.spm.stats.results.spmmat = {'), '-append', 'delimiter', '', 'newline','pc');     
    dlmwrite(write_name,['''' P ''''], '-append', 'delimiter', '', 'newline','pc');
    dlmwrite(write_name,'};', '-append', 'delimiter', '', 'newline','pc');
    
    dlmwrite(write_name,strcat('matlabbatch{', num2str(j), '}.spm.stats.results.conspec.titlestr = '''';'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{', num2str(j), '}.spm.stats.results.conspec.contrasts = Inf;'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{', num2str(j), '}.spm.stats.results.conspec.threshdesc = ''none'';'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{', num2str(j), '}.spm.stats.results.conspec.thresh = 0.001;'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{', num2str(j), '}.spm.stats.results.conspec.extent = 10;'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{', num2str(j), '}.spm.stats.results.conspec.mask = struct(''contrasts'', {}, ''thresh'', {}, ''mtype'', {});'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{', num2str(j), '}.spm.stats.results.units = 1;'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{', num2str(j), '}.spm.stats.results.print = true;'), '-append', 'delimiter', '', 'newline','pc'); 

end

fprintf('\n-----Check the created job file(.m): %s \n-----Then run the job file in either SPM8 or Grocer!\n',write_name)