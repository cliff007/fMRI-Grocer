function FG_module_write_funImgs(root_dir,groups,dirs,g,i,fun_imgs,write_name,file_filter,h_files,opts)

        % files writing
        if strcmp(h_files,opts.files.oper{1})
            for j=1:size(fun_imgs,1)
                dlmwrite(write_name,strcat('''', [root_dir,deblank(groups(g,:)), filesep,deblank(dirs(i,:)),filesep,deblank(fun_imgs(j,:))], ',1'''), '-append', 'delimiter', '', 'newline','pc');
            end
        elseif strcmp(h_files,opts.files.oper{2})            
            for j=1:size(fun_imgs{g},1)
                dlmwrite(write_name,strcat('''', [root_dir,deblank(groups(g,:)), filesep,deblank(dirs(i,:)),filesep,deblank(fun_imgs{g}(j,:))], ',1'''), '-append', 'delimiter', '', 'newline','pc');
            end  
        elseif strcmp(h_files,opts.files.oper{3})              
            fun_imgs=spm_select('FPList',[root_dir,deblank(groups(g,:)), filesep,deblank(dirs(i,:))],file_filter);
            for j=1:size(fun_imgs,1)
                dlmwrite(write_name,strcat('''', deblank(fun_imgs(j,:)), ',1'''), '-append', 'delimiter', '', 'newline','pc');
            end            
        end