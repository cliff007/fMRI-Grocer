function new_vec=FG_insert_cell_number_to_vector(ini_vec,new_vals,new_val_location)
%% transpose the new_val and new_val_location to the same vector as ini_vec if necessary
% be careful: you'd better to use 0, 1.5, 2.7... to specify the location
% where you want to insert the values
vec_L=0;
if size(ini_vec,1)==length(ini_vec),vec_L=1;end

if vec_L
    if size(new_vals,1)~=length(new_vals) 
        new_vals=new_vals';
    end
    if size(new_val_location,1)~=length(new_val_location) 
        new_val_location=new_val_location';
    end
else
    if size(new_vals,2)~=length(new_vals) 
        new_vals=new_vals';
    end
    if size(new_val_location,2)~=length(new_val_location) 
        new_val_location=new_val_location';
    end    
end

%%% for cell vector
if iscell(ini_vec)  
    
end


%%% for char vector
if ischar(ini_vec)
    
end


%%% for numeric vector
if isnumeric (ini_vec) 
        % A = 1:10; % Initial vector
        % B = [30 0 100]; % Values to insert which include a Zero
        % Bi = [3 5 10]; % Index of current A where the values are to be inserted.
        %   ---- Then ----
        % Anew = zeros(1,length(A)+length(B)) + NaN;
        % Anew(Bi+(0:length(Bi)-1)) = B;
        % Anew(isnan(Anew)) = A   
    if length(new_vals)~= length(new_val_location)   
        printf('\n-------the number of the new values being inserted is different from the corresponding location numbers\n')
        return
    end
    
%             %%%%  Method 1
%             % actually, this method is suitable for the situations that either the ini_vec/new_vals has NaN values or not
%                 new_vec=zeros(1,length(ini_vec)+length(new_vals)) + NaN;  % make a NaN vector that has the final vector length
%                 all_location=1:length(new_vec);
%                 tem=(0:length(new_vals)-1);
% 
%                 if vec_L
%                     new_vec=new_vec';
%                     all_location=all_location';
%                     tem=tem';
%                 end
% 
%                 location_of_new_val_after_insert=new_val_location+tem;        
%                 rest_location=~ismember(all_location,location_of_new_val_after_insert);
%                 rest_location=all_location(find(rest_location==1));
%                 new_vec(location_of_new_val_after_insert) = new_vals; % insert the new_vals into the NaN vector
%                 new_vec(rest_location) = ini_vec; % make the rest NaN-elements's value in the NaN vector equal to the original vector
        
     %%%%  Method 2
        if vec_L
            new_vec=[ini_vec;new_vals]; % mix these two vectors
            tem=[(1:length(ini_vec))' ; new_val_location];
            [ind_1,ind_2]=sort(tem); % sort it and get the location index ---ind2
            new_vec=new_vec(ind_2); % reshuffle the new_vec by ind2
        else
            new_vec=[ini_vec,new_vals]; % mix these two vectors
            tem=[(1:length(ini_vec)),new_val_location];
            [ind_1,ind_2]=sort(tem); % sort it and get the location index ---ind2
            new_vec=new_vec(ind_2); % reshuffle the new_vec by ind2
        end     

end
