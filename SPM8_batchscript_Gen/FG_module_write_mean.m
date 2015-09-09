function FG_module_write_mean(root_dir,groups,dirs,g,i,mean_fun_imgs,write_name,mean_file_filter,h_mean,opts)

        % files writing
        if strcmp(h_mean,opts.mean.oper{1})
           dlmwrite(write_name,strcat('''',[root_dir,deblank(groups(g,:)), filesep,deblank(dirs(i,:)),filesep,deblank(mean_fun_imgs(1,:))], ',1'''), '-append', 'delimiter', '', 'newline','pc');                
        elseif strcmp(h_mean,opts.mean.oper{2})            
           dlmwrite(write_name,strcat('''',[root_dir,deblank(groups(g,:)), filesep,deblank(dirs(i,:)),filesep,deblank(mean_fun_imgs{g}(1,:))], ',1'''), '-append', 'delimiter', '', 'newline','pc');                
        elseif strcmp(h_mean,opts.mean.oper{3})              
            mean_fun_imgs=spm_select('FPList',[root_dir,deblank(groups(g,:)), filesep,deblank(dirs(i,:))],mean_file_filter);
            dlmwrite(write_name,strcat('''',deblank(mean_fun_imgs(1,:)), ',1'''), '-append', 'delimiter', '', 'newline','pc'); 
        end 