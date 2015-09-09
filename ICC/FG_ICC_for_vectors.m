function FG_ICC_for_vectors
% You need to store the measurements column by column�� each time of
% measurement store in a separate file ('.txt|.mat|.csv')

% You need to select more than two(including two) files, and the number of columns in
% each file should be the same, and the columns in a file should couple
% with the columns in other file(s)


% import the data in the files in the matrix
    clc
    root_dir = spm_select(1,'dir','Select the folder to store the output files(csv & txt)', [],pwd);
      if isempty(root_dir)
        return
      end

File = spm_select(inf,'any','Select at least two coupling measurement files', [],pwd,'.*txt$|.*mat$|.*csv$');
[a,b,c,d]=fileparts(deblank(File(1,:)));
F_num=size(File,1);
switch c
    case {'.txt'}
        T={};
            for i=1:F_num
                tem=load(deblank(File(i,:)));
                T=[T,{tem}]; 
            end
    case {'.mat'}
        T={};
        for i=1:F_num
            tem=struct2array(load(deblank(File(i,:))));
            T=[T,{tem}]; 
        end
        
    case '.csv'   
        T={};
        for i=1:F_num
            tem=csvread(deblank(File(i,:)));
            T=[T,{tem}]; 
        end
end

% read the coupling data in the matrix one by one and do the ICC
% calculation

    % specify the num of imgs in each subject's dir
    dlg_prompt={'ICC-type (read <McGraw (1996)> and <FG_ICC.m> to select): ','ICC-Alpha Level:','ICC-base line:'};
    dlg_name='ICC parameters setup.....';
    dlg_def={'C-k (1-1; 1-k; C-1; A-1; A-k)','0.05','0'};
    %%
        % ICC(1,1): used when each subject is rated by multiple raters, raters assumed to be randomly assigned to subjects, all subjects have the same number of raters.
        % ICC(2,1): used when all subjects are rated by the same raters who are assumed to be a random subset of all possible raters.
        % ICC(3,1): used when all subjects are rated by the same raters who are assumed to be the entire population of raters.
        % ICC(1,k): Same assumptions as ICC(1,1) but reliability for the mean of k ratings.
        % ICC(2,k): Same assumptions as ICC(2,1) but reliability for the mean of k ratings.
        % ICC(3,k): Same assumptions as ICC(3,1) but reliability for the
        % mean of k ratings. Assumes additionally no subject by judges
        % interaction. 
   % dlg_def={'2','1-1','0.05','0'};
    Ans=inputdlg(dlg_prompt,dlg_name,1,dlg_def); 
    
    
    r=[]; LB=[]; UB=[]; F=[]; df1=[]; df2=[]; p=[];
    for j=1:size(T{1},2)
        M=[];        
        for i=1:F_num
            M=[M T{i}(:,j)];
        end
            [r1, LB1, UB1, F1, df11, df21, p1] = FG_ICC(M, deblank(Ans{1}), str2num(Ans{2}), str2num(Ans{3}));
            r=[r,r1]; LB=[LB,LB1]; UB=[UB,UB1]; F=[F,F1]; df1=[df1,df11]; df2=[df2,df21]; p=[p,p1];        
    end
    
    out_name='ICC_output_parameters';
    dlmwrite([out_name,'.txt'],'------The output parameters in CSV file-------', 'delimiter', '', 'newline','pc'); 
    dlmwrite([out_name,'.txt'],['--Totally you selected ' num2str(F_num) 'files, and ', num2str(size(T{1},2)) 'columns in the first file(should be same for each file)--------'], '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite([out_name,'.txt'],'--The columns in the CSV corresponding to the columns in your selected file-----', '-append','delimiter', '','newline','pc');     
    dlmwrite([out_name,'.txt'],'--Each value of a column in the CSV means:', '-append','delimiter', '','newline','pc'); 
    dlmwrite([out_name,'.txt'],'   r', '-append','delimiter', '','newline','pc'); 
    dlmwrite([out_name,'.txt'],'   p', '-append','delimiter', '','newline','pc');  
    dlmwrite([out_name,'.txt'],'   LB', '-append','delimiter', '','newline','pc');     
    dlmwrite([out_name,'.txt'],'   UB', '-append','delimiter', '','newline','pc');     
    dlmwrite([out_name,'.txt'],'   F', '-append','delimiter', '','newline','pc'); 
    dlmwrite([out_name,'.txt'],'   df1', '-append','delimiter', '','newline','pc');    
    dlmwrite([out_name,'.txt'],'   df2', '-append','delimiter', '','newline','pc');     
         
    dlmwrite([out_name,'.txt'],['-----the ICC parameters:    ',deblank(Ans{1}),'    ',Ans{2},'    ',Ans{3}], '-append','delimiter', '','newline','pc'); 
    csvwrite([out_name '.csv'],[r; LB; UB; F; df1; df2; p]);

    
    fprintf('\n-----All set!\n')
    