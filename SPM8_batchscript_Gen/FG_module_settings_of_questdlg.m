function opts=FG_module_settings_of_questdlg
        
opts.files.prom=['Are the image-file names under each subject folder of all groups same?'];
opts.files.title=['Hi...'];
opts.files.oper=[{'select one group to represent all'};
            {'No(select files group by group)'};
            {'Select all files automatically'}];
        
        
opts.folders.prom=['Are the subject-folder names of all groups same?'];
opts.folders.title=['Hi...'];
opts.folders.oper=[{'Yes(select one group to represent all)'};
            {'No(select folders group by group)'};
            {'Select all folders automatically'}];
        
opts.t1.prom=['How to apply T1 imgs?'];
opts.t1.title=['Hi...'];
opts.t1.oper=[{'select one group to represent all'};
            {'select T1s group by group'}];
        
opts.t1_sn.prom=['How to apply T1_sn.mat files?'];
opts.t1_sn.title=['Hi...'];
opts.t1_sn.oper=[{'select one group to represent all'};
            {'select T1_sn file group by group'}];      
        
        
opts.mean.prom=['How to select mean-img?'];
opts.mean.title=['Hi...'];
opts.mean.oper=[{'select one group to represent all'};
            {'select mean-img group by group'};
            {'Select mean-img automatically'}];  
        
        
opts.ST.prom=['How to apply the slice-timing parameters?'];
opts.ST.title=['Hi...'];
opts.ST.oper=[{'Enter only one group to represent all'};
            {'Enter for each group separately'}];      
        
        
opts.mask.prom=['How to apply individual (native-space) mask imgs?'];
opts.mask.title=['Hi...'];
opts.mask.oper=[{'select one group to represent all'};
            {'select mask group by group'}];           
        
        

        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        