function Vout=FG_interleave_two_vectors(V1,V2)
if isnumeric(V1)
    n_V1=size(V1,1);
    n_V2=size(V2,1);
    step=min(n_V1,n_V2);
    t=n_V1-n_V2;

    Vout=[];
    if t==0
        for i=1:step
            Vout=[Vout;V1(i);V2(i)];    
        end
    elseif t<0
        for i=1:step
            Vout=[Vout;V1(i);V2(i)];    
        end   
        Vout=[Vout;V2(step+1:end,:)];
    elseif t>0
        for i=1:step
            Vout=[Vout;V1(i);V2(i)];    
        end   
        Vout=[Vout;V1(step+1:end,:)];
    end   
elseif ischar(V1)
    n_V1=size(V1,1);
    n_V2=size(V2,1);
    step=min(n_V1,n_V2);
    t=n_V1-n_V2;

    Vout=[];
    if t==0
        for i=1:step
            Vout=strvcat(Vout,V1(i,:),V2(i,:));    
        end
    elseif t<0
        for i=1:step
            Vout=strvcat(Vout,V1(i,:),V2(i,:));     
        end   
        Vout=strvcat(Vout,V2(step+1:end,:));
    elseif t>0
        for i=1:step
            Vout=strvcat(Vout,V1(i,:),V2(i,:));      
        end   
        Vout=strvcat(Vout,V1(step+1:end,:));
    end     
    
elseif iscell(V1)
    n_V1=size(V1,1);
    n_V2=size(V2,1);
    step=min(n_V1,n_V2);
    t=n_V1-n_V2;

    Vout={};
    if t==0
        for i=1:step
            Vout=[Vout;V1{i};V2{i}];    
        end
    elseif t<0
        for i=1:step
            Vout=[Vout;V1{i};V2{i}];    
        end   
        Vout=[Vout;V2{step+1:end,:}];
    elseif t>0
        for i=1:step
            Vout=[Vout;V1{i};V2{i}];    
        end   
        Vout=[Vout;V1{step+1:end,:}];
    end         
end

fprintf('\n---Interleaving vectors is done...\n')