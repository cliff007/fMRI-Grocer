function new_name=FG_check_and_rename_existed_file(old_name,op)
% op = operation
    if nargin<1       
       fprintf('\n---ERROR: Please give an ''old_name'' as an input to quote this function...\n')
       return
    elseif nargin==1 
        op='rename';
    end

    rename_times=0;
    new_name=renaming(old_name,op,rename_times);
    
    % subfunction
    function  new_name=renaming(old_name,op,rename_times)
    if rename_times==0
        substr='';
    else 
        substr=['_' num2str(rename_times)];
    end
    
    if strcmp(op,'rename')
    
        [a,b,c,d]=fileparts(old_name);
        if ~isempty(a)
            a=[a filesep];
        end

        if exist(old_name)==2
            new_name=[a b substr c]; % rename by subfixing
        else
            new_name=old_name;  % no change
            return
        end

        if exist(new_name,'file') ==2 % self_quote to check the new name
            rename_times=rename_times+1;
            new_name=renaming(old_name,op,rename_times);
        end
        
    elseif strcmp(op,'overwrite')
        
        [a,b,c,d]=fileparts(old_name);
        if ~isempty(a)
            a=[a filesep];
        end

       if exist(old_name,'file')==2
            fprintf('Caution: %s has been created before, file will be overwritten!',old_name); % tips to overwrite
       end
     
        
    end

