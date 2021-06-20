%Graph Seed 1 to Seed 6

figFlp =figure('Name', 'Flapwise-Moment','Position', [50 100 600 500]),
subplot(2, 2, 1)
title('Flapwise-Moment Blade 1')
hold on
xlabel('Wind Speed [m/s]','FontSize',10);
ylabel('Moment [kNm]','FontSize',10);
hold on
load 'calmSeaHighWindS1'
lineFlp1 = plot(v, Flp1, 'r')
hold on
load 'calmSeaHighWindS2'
lineFlp2 = plot(v, Flp1, 'b')
hold on
load 'calmSeaHighWindS3'
lineFlp3 = plot(v, Flp1, 'g')
hold on
load 'calmSeaHighWindS4'
lineFlp4 = plot(v, Flp1, 'k')
hold on
load 'calmSeaHighWindS5'
lineFlp5 = plot(v, Flp1, 'y')
hold on
load 'calmSeaHighWindS6'
lineFlp6 = plot(v, Flp1, 'c')
hold on

subplot(2, 2, 2)
title('Flapwise-Moment Blade 2')
hold on
xlabel('Wind Speed [m/s]','FontSize',10);
ylabel('Moment [kNm]','FontSize',10);
hold on
load 'calmSeaHighWindS1'
plot(v, Flp2, 'r')
hold on
load 'calmSeaHighWindS2'
plot(v, Flp2, 'b')
hold on
load 'calmSeaHighWindS3'
plot(v, Flp2, 'g')
hold on
load 'calmSeaHighWindS4'
plot(v, Flp2, 'k')
hold on
load 'calmSeaHighWindS5'
plot(v, Flp2, 'y')
hold on
load 'calmSeaHighWindS6'
plot(v, Flp2, 'c')
hold on

subplot(2, 2, 3)
title('Flapwise-Moment Blade 3')
hold on
xlabel('Wind Speed [m/s]','FontSize',10);
ylabel('Moment [kNm]','FontSize',10);
hold on
load 'calmSeaHighWindS1'
plot(v, Flp3, 'r')
hold on
load 'calmSeaHighWindS2'
plot(v, Flp3, 'b')
hold on
load 'calmSeaHighWindS3'
plot(v, Flp3, 'g')
hold on
load 'calmSeaHighWindS4'
plot(v, Flp3, 'k')
hold on
load 'calmSeaHighWindS5'
plot(v, Flp3, 'y')
hold on
load 'calmSeaHighWindS6'
plot(v, Flp3, 'c')

L = legend([lineFlp1, lineFlp2, lineFlp3, lineFlp4, lineFlp5, lineFlp6],{'Seed 1','seed 2','Seed 3','Seed 4','Seed 5','Seed 6'});
set(L,'Position', [0.6, 0.1, 0.2, 0.25])


figEdg =figure('Name', 'Edgewise-Moment','Position', [650 100 600 500]),
subplot(2, 2, 1)
title('Edgewise-Moment Blade 1')
hold on
xlabel('Wind Speed [m/s]','FontSize',10);
ylabel('Moment [kNm]','FontSize',10);
hold on
load 'calmSeaHighWindS1'
lineEdg1 = plot(v, Edg1, 'r')
hold on
load 'calmSeaHighWindS2'
lineEdg2 = plot(v, Edg1, 'b')
hold on
load 'calmSeaHighWindS3'
lineEdg3 = plot(v, Edg1, 'g')
hold on
load 'calmSeaHighWindS4'
lineEdg4 = plot(v, Edg1, 'k')
hold on
load 'calmSeaHighWindS5'
lineEdg5 = plot(v, Edg1, 'y')
hold on
load 'calmSeaHighWindS6'
lineEdg6 = plot(v, Edg1, 'c')
hold on

subplot(2, 2, 2)
title('Edgewise-Moment Blade 2')
hold on
xlabel('Wind Speed [m/s]','FontSize',10);
ylabel('Moment [kNm]','FontSize',10);
hold on
load 'calmSeaHighWindS1'
plot(v, Edg2, 'r')
hold on
load 'calmSeaHighWindS2'
plot(v, Edg2, 'b')
hold on
load 'calmSeaHighWindS3'
plot(v, Edg2, 'g')
hold on
load 'calmSeaHighWindS4'
plot(v, Edg2, 'k')
hold on
load 'calmSeaHighWindS5'
plot(v, Edg2, 'y')
hold on
load 'calmSeaHighWindS6'
plot(v, Edg2, 'c')
hold on

subplot(2, 2, 3)
title('Edgewise-Moment Blade 3')
hold on
xlabel('Wind Speed [m/s]','FontSize',10);
ylabel('Moment [kNm]','FontSize',10);
hold on
load 'calmSeaHighWindS1'
plot(v, Edg3, 'r')
hold on
load 'calmSeaHighWindS2'
plot(v, Edg3, 'b')
hold on
load 'calmSeaHighWindS3'
plot(v, Edg3, 'g')
hold on
load 'calmSeaHighWindS4'
plot(v, Edg3, 'k')
hold on
load 'calmSeaHighWindS5'
plot(v, Edg3, 'y')
hold on
load 'calmSeaHighWindS6'
plot(v, Edg3, 'c')

L2 = legend([lineEdg1, lineEdg2, lineEdg3, lineEdg4, lineEdg5, lineEdg6],{'Seed 1','seed 2','Seed 3','Seed 4','Seed 5','Seed 6'});
set(L2,'Position', [0.6, 0.1, 0.2, 0.25])


figBld =figure('Name', 'Resultant Blade-Moment','Position', [50 100 600 500]),
subplot(2, 2, 1)
title('Resultant Blade-Moment 1')
hold on
xlabel('Wind Speed [m/s]','FontSize',10);
ylabel('Moment [kNm]','FontSize',10);
hold on
load 'calmSeaHighWindS1'
lineFlp1 = plot(v, Bld1, 'r')
hold on
load 'calmSeaHighWindS2'
lineFlp2 = plot(v, Bld1, 'b')
hold on
load 'calmSeaHighWindS3'
lineFlp3 = plot(v, Bld1, 'g')
hold on
load 'calmSeaHighWindS4'
lineFlp4 = plot(v, Bld1, 'k')
hold on
load 'calmSeaHighWindS5'
lineFlp5 = plot(v, Bld1, 'y')
hold on
load 'calmSeaHighWindS6'
lineFlp6 = plot(v, Bld1, 'c')
hold on

subplot(2, 2, 2)
title('Resultant Blade-Moment 2')
hold on
xlabel('Wind Speed [m/s]','FontSize',10);
ylabel('Moment [kNm]','FontSize',10);
hold on
load 'calmSeaHighWindS1'
plot(v, Bld2, 'r')
hold on
load 'calmSeaHighWindS2'
plot(v, Bld2, 'b')
hold on
load 'calmSeaHighWindS3'
plot(v, Bld2, 'g')
hold on
load 'calmSeaHighWindS4'
plot(v, Bld2, 'k')
hold on
load 'calmSeaHighWindS5'
plot(v, Bld2, 'y')
hold on
load 'calmSeaHighWindS6'
plot(v, Bld2, 'c')
hold on

subplot(2, 2, 3)
title('Resultant Blade-Moment 3')
hold on
xlabel('Wind Speed [m/s]','FontSize',10);
ylabel('Moment [kNm]','FontSize',10);
hold on
load 'calmSeaHighWindS1'
plot(v, Bld3, 'r')
hold on
load 'calmSeaHighWindS2'
plot(v, Bld3, 'b')
hold on
load 'calmSeaHighWindS3'
plot(v, Bld3, 'g')
hold on
load 'calmSeaHighWindS4'
plot(v, Bld3, 'k')
hold on
load 'calmSeaHighWindS5'
plot(v, Bld3, 'y')
hold on
load 'calmSeaHighWindS6'
plot(v, Bld3, 'c')

L = legend([lineFlp1, lineFlp2, lineFlp3, lineFlp4, lineFlp5, lineFlp6],{'Seed 1','seed 2','Seed 3','Seed 4','Seed 5','Seed 6'});
set(L,'Position', [0.6, 0.1, 0.2, 0.25])


figOvr =figure('Name', 'Overturning-Moment','Position', [1200 400 300 250]),
title('Overturning-Moment')
hold on
xlabel('Wind Speed [m/s]','FontSize',10);
ylabel('Moment [kNm]','FontSize',10);
hold on
load 'calmSeaHighWindS1'
plot(v, Ovr, 'r')
hold on
load 'calmSeaHighWindS2'
plot(v, Ovr, 'b')
hold on
load 'calmSeaHighWindS3'
plot(v, Ovr, 'g')
hold on
load 'calmSeaHighWindS4'
plot(v, Ovr, 'k')
hold on
load 'calmSeaHighWindS5'
plot(v, Ovr, 'y')
hold on
load 'calmSeaHighWindS6'
plot(v, Ovr, 'c')
hold on
legend('Seed 1', 'Seed 2', 'Seed 3', 'Seed 4', 'Seed 5', 'Seed 6')

