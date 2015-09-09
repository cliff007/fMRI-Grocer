function [h_SLTiming,Ans]=FG_module_select_slicetiming_paras(groups,opts)

if nargin==0
  groups = FG_module_select_groups; 
  opts=FG_module_settings_of_questdlg;
end    


% specify slice-timing parameters  
h_SLTiming=questdlg(opts.ST.prom,opts.ST.title,opts.ST.oper{1},opts.ST.oper{2},opts.ST.oper{1}) ;
if FG_check_ifempty_return(h_SLTiming), return; end

    prompt = {'total slice num:','TR:','TA(=TR-TR/nslice)[Be cautious if your data have a gap between two volume acquirsions]:','slice order:','reference slice:'};
    num_lines = 1;
    def = {'32','2','2-2/32', '[2:2:32 1:2:31]','32'};

    if strcmp(h_SLTiming,opts.ST.oper{1})
        dlg_title = ['parameters for all groups'];
        Ans{1} = inputdlg(prompt,dlg_title,num_lines,def); 
        if FG_check_ifempty_return(Ans{1}), Ans='return'; return; end
    elseif strcmp(h_SLTiming,opts.ST.oper{2})
        for g=1:size(groups,1)
            dlg_title = ['parameters for group:' groups(g,:)];
            Ans{g} = inputdlg(prompt,dlg_title,num_lines,def); 
            if FG_check_ifempty_return(Ans{g}),  Ans='return'; return; end
        end            
    end  