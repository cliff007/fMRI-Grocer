function varargout=FG_get_corresponding_pair_img(num_vector,label_way)   
% label_way=1  ,% default: ASL data are acquired in a control-label way
% label_way=0  ,% default: ASL data are acquired in a label-control way
        num_vector=num_vector(:);
        if label_way
          for i=1:length(num_vector) 
              if rem(num_vector(i),2)==0
                  motion_pair(i)=num_vector(i)-1;
              else
                  motion_pair(i)=num_vector(i)+1;
              end
          end
       else
          for i=1:length(num_vector) 
              if rem(num_vector(i),2)==0
                  motion_pair(i)=num_vector(i)+1;
              else
                  motion_pair(i)=num_vector(i)-1;
              end
          end
        end
       
        motion_pair=motion_pair(:);
        unique_pairs=unique(sort([motion_pair(:);num_vector(:)]));
        
        if nargout>0
            varargout={motion_pair;unique_pairs};
        end
        
        