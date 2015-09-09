function T_Ans=FG_inputdlg_selfdefined(rows,default_row_name,dlg_name,def_val)
            if nargin==0
                rows=2;
                default_row_name='row';
                def_val=[0 0];
                dlg_name='Row value setting';
            elseif nargin==2
                dlg_name='Row value setting';
                def_val=[1:rows]';% zeros(1,rows)'
            elseif nargin==3
                def_val=[1:rows]';% zeros(1,rows)'
            elseif nargin==4
                def_val=repmat(def_val,rows,1);
%                 def_val=FG_combine_two_str_vectors(def_val,num2str(zeros(1,rows)'));
            end
            
            dlg_prompt1={};
            dlg_prompt2={};
            dlg_prompt3={};
            for i=1:rows
                dlg_prompt1=[dlg_prompt1,[default_row_name,num2str(i),'---------            ------------------            -------']];
                dlg_prompt2=[dlg_prompt2,[default_row_name,num2str(i)]];
                if nargin<4
                    dlg_prompt3=[dlg_prompt3,num2str(def_val(i))];
                elseif nargin ==4
                    dlg_prompt3=[dlg_prompt3,num2str(def_val(i,:))];
                end
            end

%             dlg_name='Row names setting';
%             T_Ans_name=inputdlg(dlg_prompt1,dlg_name,1,dlg_prompt2,'on');  
            T_Ans_name=dlg_prompt2;
        
%             dlg_name='Row value setting';
            T_Ans=inputdlg(T_Ans_name',dlg_name,1,dlg_prompt3,'on');  
