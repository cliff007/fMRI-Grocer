function varargout=FG_write_vol(Vmat,V,new_full_name,dtype)  

if nargin==4
%     dtype='float32';
    switch lower(dtype)
            case 'uint32'
                datatype = 768;
            case 'uint16'
                datatype = 512;
            case 'int8'
                datatype = 256;
            case {'float64','double'}
                datatype = 64;
            case {'float32','single'}
                datatype = 16;
            case 'int32'
                datatype = 8;
            case 'int16'
                datatype = 4;
            case 'uint8'
                datatype = 2;
            otherwise % need to add other decription
                error('unsupported data format now.');
    end
    Vmat.dt    =[datatype,0];
end

%% FG_write_vol(Vmat,V,new_full_name)  
    new_Vmat=Vmat;
    new_Vmat.fname=deblank(new_full_name);
    spm_write_vol(new_Vmat,V);
    
    if nargout~=0
       varargout={new_full_name,new_Vmat} ;
    end
       
    