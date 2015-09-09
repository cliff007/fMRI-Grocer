function xls_col=FG_excel_column_gen(n_cycles)
clc
tem={'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'};
if nargin==0
    dlg_prompt={'How many runs of A-Z do you want to genenrate (<=26):'};
    dlg_name='Hi';
    dlg_def={'10'};
    Ans=inputdlg(dlg_prompt,dlg_name,1,dlg_def); 
    n_cycles=str2num(Ans{1});
end

loop_t=n_cycles ;  % define the repeat times, loop_t<=26
tp={};
k=1;
for i=1:loop_t
    for j=1:length(tem)
        tp{k}=[tem{i},tem{j}];
        k=length(tp)+1;
    end
end
xls_col=[tem,tp]';

fprintf('\n\ncolums letters of Excel has been display in the command window~~\n')



