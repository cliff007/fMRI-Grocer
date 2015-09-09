
%%%%  subfunction, add_filesep_at_the_end options~~
function [sorted_out,length_array,idx]=FG_sort_vector_elements_by_length(input_array,order_cend)
    % the input can be either a cell or array, and
    % each element of "input_array" can also be either a cell or array   
    % the output would be same as array structure as the input
    if nargin==0
       input_array=FG_varselect; 
       order_cend='ascend';
    elseif nargin==1
        order_cend='ascend';
    end
        
    length_array=[];
    sorted_out=[];
    
    % order_cend can either be 'ascend' or 'descend'    
    %%% Caution:       char  <====> cellstr   
    if iscell(input_array)   % judge the whole input array
       if ischar(input_array{1})  % judge the element of the cell array
           tem=cellfun(@length,input_array);
           [length_array,idx]=sort(tem,order_cend);
           for i=1:length(idx)
               sorted_out=[sorted_out;input_array(idx(i))];
           end
       elseif iscell(input_array{1})  % judge the element of the cell array
           tem=cellfun(@(x) length(x{:}),input_array);
           [length_array,idx]=sort(tem,order_cend); 
           for i=1:length(idx)
               sorted_out=[sorted_out;input_array(idx(i))];
           end           
       end
    elseif ischar(input_array)    % judge the whole input array
            tem1=cellstr(input_array);
           tem=cellfun(@length,tem1);
           [length_array,idx]=sort(tem,order_cend); 
           for i=1:length(idx)
               sorted_out=[sorted_out;tem1(idx(i))];
           end            
           sorted_out=char(sorted_out);
          
    end
    


  %%% Caution:       char  <====> cellstr   
 
    