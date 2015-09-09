function readout=FG_read_txt_row_by_row(txtfile)
if nargin==0
   txtfile=spm_select(1,'any','Select the txt file you want to read out row-by-row ...',[],pwd,'.*txt$|.*m$');
end

fidin=fopen(txtfile);                                 
readout=[];
while ~feof(fidin)                                % judge whether is the end               
     tline=fgetl(fidin);                                   % read row by row  
     readout=strvcat(readout,tline);                    % get the row data
end 
fclose(fidin); 
