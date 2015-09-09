function FG_mkdir_all_the_path(path)
% folder=[];
% rootdir=[];

if exist(path,'dir')
    fprintf('-----%s is already existed!',path)
    return;
else

    [rootdir,folder]=FG_sep_group_and_path(path);
    if exist(rootdir,'dir')
        mkdir(path) 
    else
       FG_mkdir_all_the_path(rootdir) 
    end
    
end

% while ~strcmp(rootdir(1,length(folder)-1),folder) && ~isempty(rootdir)