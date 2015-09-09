
function [FieldS,ASLT,FirstimageT,SubtractionO,SubtractionT,threshold_val,Labeltime_val,Delaytime_val,Slicetime_val,blood_T1,label_efficiency]= ...
    FG_ASL_CBF_parameters_output(FieldStrength,ASLType,FirstimageType,SubtractionOrder,SubtractionType,threshold,Labeltime,Delaytime,Slicetime,T1b,alp,pth,output_name)

    if FieldStrength==1
       FieldS='FieldStrength: 3T';
    elseif FieldStrength==2
       FieldS='FieldStrength: 1.5T'; 
    end

    if ASLType==2
       ASLT='ASLType: pcasl';
    elseif ASLType==1
       ASLT='ASLType: casl'; 
    elseif ASLType==0
       ASLT='ASLType: pasl'; 
    end


    if FirstimageType==0
       FirstimageT='FirstimageType: control';
    elseif FirstimageType==1
       FirstimageT='FirstimageType: labeled' ;
    end


    if SubtractionOrder==0
       SubtractionO='SubtractionOrder: Even-Odd(Img2-Img1)';
    elseif SubtractionOrder==1
       SubtractionO='SubtractionOrder: Odd-Even(Img1-Img2)'; 
    end


    if SubtractionType==0
       SubtractionT='SubtractionType: Simple';
    elseif SubtractionType==1
       SubtractionT='SubtractionType: Surround' ;
    elseif SubtractionType==2
       SubtractionT='SubtractionType: Sinc';   
    end


    threshold_val=['threshold =',num2str(threshold)];
    Labeltime_val=['Labeltime =',num2str(Labeltime)];
    Delaytime_val=['Delaytime =',num2str(Delaytime)];
    Slicetime_val=['Slicetime =',num2str(Slicetime)];
    blood_T1=['blood T1 =',num2str(T1b)];
    label_efficiency =['label efficiency =',num2str(alp)];
    
    
    dlmwrite(fullfile(pth,output_name), '  ', '-append','delimiter', '','newline','pc');% blank row
    dlmwrite(fullfile(pth,output_name), '  ', '-append','delimiter', '','newline','pc');% blank row
    dlmwrite(fullfile(pth,output_name), '====[5]. ASL calculation setting (parameters) summary ================', '-append','delimiter', '','newline','pc');
    dlmwrite(fullfile(pth,output_name), FieldS, '-append','delimiter', '', 'newline','pc');
    dlmwrite(fullfile(pth,output_name), ASLT, '-append','delimiter', '', 'newline','pc');
    dlmwrite(fullfile(pth,output_name), FirstimageT, '-append','delimiter', '', 'newline','pc');
    dlmwrite(fullfile(pth,output_name), SubtractionO, '-append','delimiter', '', 'newline','pc');
    dlmwrite(fullfile(pth,output_name), SubtractionT, '-append','delimiter', '', 'newline','pc');
    dlmwrite(fullfile(pth,output_name), threshold_val, '-append','delimiter', '', 'newline','pc');
    dlmwrite(fullfile(pth,output_name), Labeltime_val, '-append','delimiter', '', 'newline','pc');
    dlmwrite(fullfile(pth,output_name), Delaytime_val, '-append','delimiter', '', 'newline','pc');
    dlmwrite(fullfile(pth,output_name), Slicetime_val, '-append','delimiter', '', 'newline','pc');
    dlmwrite(fullfile(pth,output_name), blood_T1, '-append','delimiter', '', 'newline','pc');
    dlmwrite(fullfile(pth,output_name), label_efficiency, '-append','delimiter', '', 'newline','pc');
    dlmwrite(fullfile(pth,output_name), '  ', '-append','delimiter', '', 'newline','pc');
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

