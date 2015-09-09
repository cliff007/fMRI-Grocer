
function FG_pcode_all_m_files
    curr_dir=pwd;
    m_folders=spm_select(inf,'dir','Select folders containning *.m files...', [],pwd);
    if isempty(m_folders),return,end
    
    h = questdlg('Do you want to generate p-folders in the same root folder as the input folders or in the current directory?','Same root folder or not...','Same root directory','Current directory','Current directory') ;
    for i=1:size(m_folders,1)
        m_folder=deblank(m_folders(i,:));
        m_files=dir(fullfile (m_folder, '*.m'));
        if isempty(m_files)
            fprintf('No *.m files found in: %s \nSkip to the next...\n',m_folder)
            continue
        end
        
        if strcmp(h,'Current directory')   
            [pth,name]=FG_sep_group_and_path(m_folder);
            outdir=[name '_pcodes'];
            mkdir(outdir)
            cd (outdir)
        elseif strcmp(h,'Same root directory')
            outdir=[m_folder(1,1:end-1) '_pcodes'];
            mkdir(outdir)
            cd (outdir)
        end
        pcode (fullfile (m_folder, '*.m'))           % genenrate p files in the current directory
        cd(curr_dir)
        fprintf('%s: is done\n',outdir)
    end
    
    
    fprintf('---All done\n')
