function FG_multi_CBF_calculation(root_dir,paras_file)
    
    FG_load_ASL_parameters(paras_file);
    Filename=FG_readsubfolders(root_dir);
    self_maskimg= spm_select('FPList',deblank(root_dir),'^resliced.*img');
    FG_Perf_ASL_CBF_SPM8_Only_one_sub_CMD(SelfmaskedorNo,Filename,self_maskimg,FieldStrength,ASLType,FirstimageType, ...
    SubtractionType,SubtractionOrder,Labeltime,Delaytime,Slicetime,PASLMo,Timeshift,threshold,alp)

