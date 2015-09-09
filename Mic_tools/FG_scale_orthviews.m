function FG_scale_orthviews(mn, mx)
%function me_scale_orthview(mn, mx)
%  mn	minimum
%  mx   maximum
% set scaling in spm_orthview to min max
global st 
% get handle of colorbar
try
	hcb=st.vols{1}.blobs{1}.ax;
catch
	hcb=findobj('tag','colorbar');
end
if isempty(hcb)
	hc=get(st.fig,'children');	% get children of fig
	%hcb=hc(1);	% hope this is always true
	hcd=get(hc, 'Children');
	for h=1:length(hcd), hs(h)=size(hcd{h},1);end
	hcd_1 = find(hs==1);		% children with only one child
	hcd2  = cat(1,hcd{hcd_1});	% children with only one child
	for h=1:length(hcd2)
		% get(hcd2(h), 'Type')
		try
			if all((size(get(hcd2(h), 'CData'))==[64,1]))
				hcb=hc(hcd_1(h));
			end
		catch
			% get(hcd2(h));
		end
	end
end

if isempty(hcb)
	fprintf('No orthviews with colorbar found!\n');
else

	% YLim=get(hcb, 'YLim');
	set(hcb, 'YLim', [mn mx]);
	set(get(hcb,'children'),'YData',[mn mx])
	% set(get(hcb,'children'),'YData',[0 mx-mn])	% ???
	st.vols{1}.blobs{1}.min=mn;
	st.vols{1}.blobs{1}.max=mx;
	spm_orthviews('redraw');

end
