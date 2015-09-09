function FG_write_out_txt(write_name,text,append_or_overwrite)
        txt_append=0;
        if nargin==2
           write_name=FG_check_and_rename_existed_file(write_name); 
        elseif nargin==3
               txt_append=1;           
        end
        
        for i=1:size(text,1)
            if nargin==3 && i==1
                if strcmpi(append_or_overwrite,'overwrite')
                    dlmwrite(write_name, deblank(text(i,:)), 'delimiter', '', 'newline','pc');
                end
            end                
            dlmwrite(write_name, deblank(text(i,:)),'-append', 'delimiter', '', 'newline','pc');
        end