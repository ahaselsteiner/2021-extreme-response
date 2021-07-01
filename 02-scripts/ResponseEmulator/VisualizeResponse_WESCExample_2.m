vid = 3;
hsid = 2;
tpid = 2;

r = squeeze(Ovr(vid, hsid, tpid, :));


fig = figure('Position', [100 100 1200 220]);
label = ['v = ' num2str(v(vid)) ' m s^{-1}, h_s = ' num2str(hs(hsid)) ' m'];
label = [label ', t_p = ' num2str(tp(hs(hsid), tpid), '%4.2f') ' s'];
plot(t, r);
xlabel('Time');
ylabel('Overturning moment (Nm)');
box off
%title(label);


exportgraphics(fig, 'gfx/WESC_timeseries.jpg') 