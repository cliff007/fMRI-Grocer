function FG_voxbo_vbrename_matlab
clc

%%%% vbrename
h=questdlg('**. It is going to do vbrename for all subject, are you sure to continue?','Step1 :VBrename....','Yes','Skip','Skip') ;

switch h
    case 'Yes'

        anyreturn=FG_modules_selection('Select the root folder containing all the subject folders','Please select all subjects...','','^','r','g');
        if anyreturn, return;end
    
        for i=1:size(groups,1) 
              eval(['! vbrename ''' deblank(groups(i,:)) ''''])
            %  eval(['system(''vbrename ' deblank(groups(i,:)) ''')'])
        end

        fprintf('Vbrenaming for your selection is done............\n\n')
        
    case 'Skip'
        fprintf('Skip the first step: vbrename............\n\n')
end


        
 