function root=FG_rootDir(tb_name)

    if nargin==0
        tb_name='fmri_grocer';
        tem=which(tb_name);
    else
        tem=which(tb_name);
    end

    if ~isempty(tem)
        [root,name,ext,even]=FG_fileparts(tem);
    else
        fprintf('\n---- %s is not installed in MATLAB....\n',tb_name)
    end
