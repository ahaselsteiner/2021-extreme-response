% In this script we analyze how well the point force based approximation 
% for the bending moment at 10 m water depth is.

% The following environmental conditions were simulated in openFAST:
% 1-hour wind speed (m/s); Hs (m); Tp (s);
% 11; 0; tp2;
% 11; 5; tp2;
% 17; 0; tp2;
% 17; 5; tp2;
% 35; 0; tp2;
% 35; 11; tp2;
% 35; 13; tp2;
% 11; 0; tp3;
% 11; 5; tp3;
% 17; 0; tp3;
% 17; 5; tp3;
% 35; 0; tp3;
% 35; 11; tp3;
% 35; 13; tp3;

maxr = max(Ovr,[],4);
maxr(maxr==0)=NaN;
maxb = max(Stat,[],5);
maxb = maxb(:, :, :, 5); % node 5 is 10 m water depth.
maxb(maxb==0)=NaN;


VBending = [11, 17, 35];
HsBending = [0, 5, 11, 13];

R = ResponseEmulator();
B = ResponseEmulator10mWaterDepth();
r_emulated = nan(size(maxr));
b_emulated = nan(size(maxr));
environmentals = cell(size(maxr));
for vid = 1 : size(maxr, 1)
    for hsid = 1: size(maxr, 2)
        for tpid = 1 : size(maxr, 3)
            if ~isnan(maxr(vid, hsid, tpid))
                vnow = VBending(vid);
                hsnow = HsBending(hsid);
                tpnow = R.tp(HsBending(hsid), tpid);
                r_emulated(vid, hsid, tpid) = R.ICDF1hr(vnow, hsnow, tpnow, 0.5);
                b_emulated(vid, hsid, tpid) = B.ICDF1hr(vnow, hsnow, tpnow, 0.5);
                environmentals{vid, hsid, tpid} = ['V = ' num2str(vnow) ' m/s, H_s = ' num2str(hsnow) ' m, T_p = ' num2str(tpnow, '%4.1f') ' s'];
            end
        end
    end
end



% Convert these tensors to 1D-vectors.
maxr = maxr(:);
mask = ~isnan(maxr);
maxr = maxr(mask) / 1E6;

maxb = maxb(:);
maxb = maxb(mask) / 1E6;

r_emulated = r_emulated(:);
r_emulated = r_emulated(mask) / 1E6;

b_emulated = b_emulated(:);
b_emulated = b_emulated(mask) / 1E6;

environmentals = environmentals(:);
environmentals  = environmentals(mask);


figure
subplot(1, 2, 1);
plot(maxb, b_emulated, '.k')
subplot(1, 2, 2);
plot(maxr, r_emulated, '.k')

fig = figure('position', [100, 100, 1000, 500]);
layout = tiledlayout(2,4);
nexttile(1,[1 3]);
x = 1:length(maxb);
bar(x, [maxb'; b_emulated']);
legend({'B_{realized}', 'B_{emulated}'}, 'Location','northoutside','NumColumns',2, 'box', 'off');
set(gca,'XTick',[])
box off
ylabel('B (MNm)');
nexttile(4)
bmean = mean(b_emulated ./ maxb);
bstd = std(b_emulated ./ maxb);
bar(1, bmean, 'FaceColor', [0.5 0.5 0.5]);
hold on
er = errorbar(1, bmean, -bstd, bstd, 'color', 'k');
box off
ylabel('B_{emulated} / B_{realized}');
nexttile(5,[1 3]);
x = 1:length(maxr);
bar(x, [maxr'; r_emulated']);
xticks(x)
set(gca,'XTickLabel',environmentals)
xtickangle(45)
box off
ylabel('R (MNm)');
nexttile(8);
rmean = mean(r_emulated ./ maxr);
rstd = std(r_emulated ./ maxr);
bar(1, rmean, 'FaceColor', [0.5 0.5 0.5]);
hold on
er = errorbar(1, rmean, -rstd, rstd, 'color', 'k');
box off
ylabel('R_{emulated} / R_{realized}');

fname = 'gfx/bending_moment_gof';
exportgraphics(layout, [fname '.jpg']) 
exportgraphics(layout, [fname '.pdf']) 
