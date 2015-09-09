function FG_switch_red_arrow_ONandOFF_in_SPM
% this funcion can let you switch on/off the red arrow in the glass brain 
% of the SPM result window
 ha = findobj('Tag','hMIPax');
 hp = get(ha,'UserData');
 
 tem=get(hp.hXr,'Visible');

 if strcmp('on',tem{1})
     set(hp.hXr,'Visible','off')
      fprintf('\n------Red Arrow OFF!\n')
 elseif strcmp('off',tem{1})
     set(hp.hXr,'Visible','on')
     fprintf('\n------Red Arrow ON!\n')
 end
 
 
 