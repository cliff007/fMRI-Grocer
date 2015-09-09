function FG_remove_ScanNum_at_the_beginning_of_each_folder
% rename sequences into the task names
        anyreturn=FG_modules_selection('Select the root folder containing all the subject folders','Please select all subjects...','','^','r','g');
        if anyreturn, return;end
    
        prompt = {'Enter the 1st keyword from which you want to keep ','2nd keyword(Keep blank if you only have one keyword)'};
        dlg_title = 'Input keywords';
        num_lines = 1;
        def = {'ep2d','MEMPRAGE'};
        keywords = inputdlg(prompt,dlg_title,num_lines,def);
        
        if isempty(keywords{2})
           keywords= keywords(1);
        elseif strcmp(keywords{2},keywords{1})
           keywords= keywords(1);
        end            
%         keywords={'ep2d','MEMPRAGE'};
        
        for i=1:size(groups,1) 
           cd (fullfile(root_dir,deblank(groups(i,:))))
           b=FG_readsubfolders(pwd);

           for j=1:size(b,1)
               tmp_name=b{j};

               for n=1:size(keywords,1)
                   tem=findstr(keywords{n},tmp_name);
                   if isempty(tem) ||  tem==1
                      continue 
                   else
                       new_tmp_name=tmp_name(1,tem:end);
                       movefile(b{j},new_tmp_name)    
                   end
               end

           end
           cd ..
           
        end   
        
        fprintf('-------All Scan number at the beginning of each scan folder has been removed............\n\n')
