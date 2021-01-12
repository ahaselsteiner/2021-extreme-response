% This script will plot the response for the calm sea
addpath('03_Calm_Sea_Complete_Wind')
load 'CalmSeaComplete.mat';
seed_line_style =  {'ok', 'ok', 'ok', 'ok', 'ok', 'ok'};


% Flapwise-Moment
figFlp = figure('Name', 'Flapwise-Moment','Position', [50 100 600 500]);
% Blade 1
subplot(2, 2, 1)
title('Flapwise-Moment Blade 1')
hold on
xlabel('Wind Speed [m/s]','FontSize',10);
ylabel('Moment [kNm]','FontSize',10);
hold on
plot (v, Flp1_S1, 'r')
hold on
plot (v, Flp1_S2, 'b')
hold on
plot (v, Flp1_S3, 'g')
hold on
plot (v, Flp1_S4, 'k')
hold on
plot (v, Flp1_S5, 'y')
hold on
plot (v, Flp1_S6, 'c')

% Blade 2
subplot (2,2,2)
title('Flapwise-Moment Blade 2')
hold on
xlabel('Wind Speed [m/s]','FontSize',10);
ylabel('Moment [kNm]','FontSize',10);
hold on
plot (v, Flp2_S1, 'r')
hold on
plot (v, Flp2_S2, 'b')
hold on
plot (v, Flp2_S3, 'g')
hold on
plot (v, Flp2_S4, 'k')
hold on
plot (v, Flp2_S5, 'y')
hold on
plot (v, Flp2_S6, 'c')

% Blade 3
subplot (2,2,3)
title('Flapwise-Moment Blade 3')
hold on
xlabel('Wind Speed [m/s]','FontSize',10);
ylabel('Moment [kNm]','FontSize',10);
hold on
plot (v, Flp3_S1, 'r')
hold on
plot (v, Flp3_S2, 'b')
hold on
plot (v, Flp3_S3, 'g')
hold on
plot (v, Flp3_S4, 'k')
hold on
plot (v, Flp3_S5, 'y')
hold on
plot (v, Flp3_S6, 'c')

LFlp = legend({'Seed 1','seed 2','Seed 3','Seed 4','Seed 5','Seed 6'});
set(LFlp,'Position', [0.6, 0.1, 0.2, 0.25])


% Edgewise-Moment
figEdg =figure('Name', 'Edgewise-Moment','Position', [50 100 600 500]),
% Blade 1
subplot(2, 2, 1)
title('Edgewise-Moment Blade 1')
hold on
xlabel('Wind Speed [m/s]','FontSize',10);
ylabel('Moment [kNm]','FontSize',10);
hold on
plot (v, Edg1_S1, 'r')
hold on
plot (v, Edg1_S2, 'b')
hold on
plot (v, Edg1_S3, 'g')
hold on
plot (v, Edg1_S4, 'k')
hold on
plot (v, Edg1_S5, 'y')
hold on
plot (v, Edg1_S6, 'c')

% Blade 2
subplot (2,2,2)
title('Edgewise-Moment Blade 2')
hold on
xlabel('Wind Speed [m/s]','FontSize',10);
ylabel('Moment [kNm]','FontSize',10);
hold on
plot (v, Edg2_S1, 'r')
hold on
plot (v, Edg2_S2, 'b')
hold on
plot (v, Edg2_S3, 'g')
hold on
plot (v, Edg2_S4, 'k')
hold on
plot (v, Edg2_S5, 'y')
hold on
plot (v, Edg2_S6, 'c')

% Blade 3
subplot (2,2,3)
title('Edgewise-Moment Blade 3')
hold on
xlabel('Wind Speed [m/s]','FontSize',10);
ylabel('Moment [kNm]','FontSize',10);
hold on
plot (v, Edg3_S1, 'r')
hold on
plot (v, Edg3_S2, 'b')
hold on
plot (v, Edg3_S3, 'g')
hold on
plot (v, Edg3_S4, 'k')
hold on
plot (v, Edg3_S5, 'y')
hold on
plot (v, Edg3_S6, 'c')

LEdg = legend({'Seed 1','seed 2','Seed 3','Seed 4','Seed 5','Seed 6'});
set(LEdg,'Position', [0.6, 0.1, 0.2, 0.25])


% Resulting Blade Moment 
figBld =figure('Name', 'Resulting-Blade-Moment','Position', [50 100 600 500]),
% Blade 1
subplot(2, 2, 1)
title('Resulting-Blade-Moment Blade 1')
hold on
xlabel('Wind Speed [m/s]','FontSize',10);
ylabel('Moment [kNm]','FontSize',10);
hold on
plot (v, Bld1_S1, 'r')
hold on
plot (v, Bld1_S2, 'b')
hold on
plot (v, Bld1_S3, 'g')
hold on
plot (v, Bld1_S4, 'k')
hold on
plot (v, Bld1_S5, 'y')
hold on
plot (v, Bld1_S6, 'c')

% Blade 2
subplot (2,2,2)
title('Resulting-Blade-Moment Blade 2')
hold on
xlabel('Wind Speed [m/s]','FontSize',10);
ylabel('Moment [kNm]','FontSize',10);
hold on
plot (v, Bld2_S1, 'r')
hold on
plot (v, Bld2_S2, 'b')
hold on
plot (v, Bld2_S3, 'g')
hold on
plot (v, Bld2_S4, 'k')
hold on
plot (v, Bld2_S5, 'y')
hold on
plot (v, Bld2_S6, 'c')

% Blade 3
subplot (2,2,3)
title('Resulting-Blade-Moment Blade 3')
hold on
xlabel('Wind Speed [m/s]','FontSize',10);
ylabel('Moment [kNm]','FontSize',10);
hold on
plot (v, Bld3_S1, 'r')
hold on
plot (v, Bld3_S2, 'b')
hold on
plot (v, Bld3_S3, 'g')
hold on
plot (v, Bld3_S4, 'k')
hold on
plot (v, Bld3_S5, 'y')
hold on
plot (v, Bld3_S6, 'c')

LBld = legend({'Seed 1','seed 2','Seed 3','Seed 4','Seed 5','Seed 6'});
set(LBld,'Position', [0.6, 0.1, 0.2, 0.25])


% Overturning-Moment
OvrAllSeeds = [Ovr_S1; Ovr_S2; Ovr_S3; Ovr_S4; Ovr_S5; Ovr_S6];
figOvr = figure('Name', 'Overturning-Moment','Position', [50 100 600 500]);
hold on
ms = 50;
for i = 1 : 6
    h = scatter(v, OvrAllSeeds(i,:), ms, 'MarkerFaceColor', [0.5 0.5 0.5], ...
    'MarkerFaceAlpha', 0.5, 'MarkerEdgeColor', 'k')
    if i > 1 
        set(h, 'HandleVisibility', 'off')
    end
end

v_lim = 60;

meanOvr = mean(OvrAllSeeds);
plot(v, meanOvr, '-k', 'linewidth', 2);
FT = fittype('a * x.^2');
fitted_curve = fit(v(v > 25 & v <= v_lim)', meanOvr(v > 25 & v <= v_lim)', FT);
h = plot(fitted_curve);
set(h, 'linewidth', 2)
set(h, 'linestyle', '--')
xlabel('Wind speed (m/s)', 'FontSize', 10);
ylabel('Overturning moment (Nm)', 'FontSize', 10);
fit_string = [num2str(round(fitted_curve.a)) ' * v^2'];
legend({'Simulation seed', 'Average over seeds', fit_string}, 'location', 'northwest');
legend box off

xlim([0 v_lim])
V50AtHub = 28.6 / (10/87.6)^0.14
