% Plot Full Range Calm Sea

load 'Full_Range_Calm_Sea.mat';

% Flapwise-Moment
figFlp =figure('Name', 'Flapwise-Moment','Position', [50 100 600 500]),
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
figOvr =figure('Name', 'Overturning-Moment','Position', [50 100 600 250]),
subplot (1, 2, 1)
title('Overturning-Moment')
hold on
xlabel('Wind Speed [m/s]','FontSize',10);
ylabel('Moment [kNm]','FontSize',10);
hold on
plot (v, Ovr_S1, 'r')
hold on
plot (v, Ovr_S2, 'b')
hold on
plot (v, Ovr_S3, 'g')
hold on
plot (v, Ovr_S4, 'k')
hold on
plot (v, Ovr_S5, 'y')
hold on
plot (v, Ovr_S6, 'c')

LOvr = legend({'Seed 1','seed 2','Seed 3','Seed 4','Seed 5','Seed 6'});
set(LOvr,'Position', [0.65, 0.3, 0.2, 0.5])
