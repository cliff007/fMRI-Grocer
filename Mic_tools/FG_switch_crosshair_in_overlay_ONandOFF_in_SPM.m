function FG_switch_crosshair_in_overlay_ONandOFF_in_SPM
% this funcion can let you switch on/off the red arrow in the glass brain 
% of the SPM result window
 
 h_on_off=questdlg('Switch the crosshair ON or OFF?','Hi....','ON','OFF','ON') ;
 if strcmp(h_on_off,'ON')
    spm_orthviews('Xhairs','on')
 else
    spm_orthviews('Xhairs','off')    
 end
 fprintf('\n---Now the crosshairs in the SPM overlay viewer is %s\n',h_on_off)
 
 
% 
%         spm_orthviews('Xhairs',varargin{2});
%         cm_handles = get_cm_handles;
%         for i = 1:numel(cm_handles),
%             z_handle = get(findobj(cm_handles(i),'label','Crosshairs'),'Children');
%             set(z_handle,'Checked','off'); %reset check
%             if strcmp(varargin{2},'off'), op = 1; else op = 2; end
%             set(z_handle(op),'Checked','on');
%         end;
% 
% 
% 
%         % subfunction in   [ spm_orthviews  ]   
%         function cm_handles = get_cm_handles
%         global st
%         cm_handles = [];
%         for i=valid_handles(1:24),
%             cm_handles = [cm_handles st.vols{i}.ax{1}.cm];
%         end
%         return;   

        
        
        

 
 