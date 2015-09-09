%%%%  subfunction, add_filesep_at_the_end options~~
function output_array=FG_add_characters_at_the_end(input_array,chars)
    % the input can be either a cell or array, and
    % each element of "input_array" can also be either a cell or array   
    % the output would be same as array structure as the input
    output_array=[];
    %%% Caution:       char  <====> cellstr   
    if iscell(input_array)   % judge the whole input array
       [m,n]=size(input_array);
       if ischar(input_array{1})  % judge the element of the cell array
            for i=1:length(input_array)
                tem=deblank(input_array{i});
                output_array{i}=[tem,chars];
            end
       elseif iscell(input_array{1})  % judge the element of the cell array
             for i=1:length(input_array)
                tem=deblank(input_array{i}(1,:));
                output_array{i}={[tem,chars]};
            end   
       end
        if ~isempty(output_array) && m>n
            output_array=output_array';
        end
    elseif ischar(input_array)    % judge the whole input array
        for i=1:size(input_array,1)
            tem=deblank(input_array(i,:));
            output_array{i}=[tem,chars];

        end   
        if ~isempty(output_array)
            output_array=char(output_array);
        end
    end
    


  %%% Caution:       char  <====> cellstr   
 
    