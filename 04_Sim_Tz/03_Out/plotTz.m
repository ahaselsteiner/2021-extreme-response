% Plot Diagrams Simulation Tz

figOvrTz = figure ('Position', [25 25 1500 750])
subplot (2,2,1)
title('Windspeed 11.4 m/s, Significant wave height 1 m')
xlabel('Peak-spectral period [s]','FontSize',10);
ylabel('Overturning-Moment [Nm]','FontSize',10);
grid on
hold on
load 'Hs1_S1.mat';
Ovr_Tz2 = Ovr(1);
Ovr_Tz3 = Ovr(2);
Ovr_Tz4 = Ovr(3);
Ovr_Tz5 = Ovr(4);
Ovr_Tz6 = Ovr(5);
Ovr_Tz7 = Ovr(6);
Ovr_Tz8 = Ovr(7);
Ovr_Tz9 = Ovr(8);
lineS1 = plot (Tz (1), Ovr(2), 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'r');
hold on
plot (Tz (2), Ovr(2), 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'r');
hold on
plot (Tz (3), Ovr(3), 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'r');
hold on
plot (Tz (4), Ovr(4), 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'r');
hold on
plot (Tz (5), Ovr(5), 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'r');
hold on
plot (Tz (6), Ovr(6), 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'r');
hold on
plot (Tz (7), Ovr(7), 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'r');
hold on
plot (Tz (8), Ovr(8), 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'r');
hold on


load 'Hs1_S2.mat';
Ovr_Tz2 = [Ovr_Tz2 Ovr(1)];
Ovr_Tz3 = [Ovr_Tz3 Ovr(2)];
Ovr_Tz4 = [Ovr_Tz4 Ovr(3)];
Ovr_Tz5 = [Ovr_Tz5 Ovr(4)];
Ovr_Tz6 = [Ovr_Tz6 Ovr(5)];
Ovr_Tz7 = [Ovr_Tz7 Ovr(6)];
Ovr_Tz8 = [Ovr_Tz8 Ovr(7)];
Ovr_Tz9 = [Ovr_Tz9 Ovr(8)];
lineS2 =plot (Tz (1), Ovr(1), 'o', 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'b');
hold on
plot (Tz (2), Ovr(2), 'o', 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'b');
hold on
plot (Tz (3), Ovr(3), 'o', 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'b');
hold on
plot (Tz (4), Ovr(4), 'o', 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'b');
hold on
plot (Tz (5), Ovr(5), 'o', 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'b');
hold on
plot (Tz (6), Ovr(6), 'o', 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'b');
hold on
plot (Tz (7), Ovr(7), 'o', 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'b');
hold on
plot (Tz (8), Ovr(8), 'o', 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'b');
hold on


load 'Hs1_S3.mat';
Ovr_Tz2 = [Ovr_Tz2 Ovr(1)];
Ovr_Tz3 = [Ovr_Tz3 Ovr(2)];
Ovr_Tz4 = [Ovr_Tz4 Ovr(3)];
Ovr_Tz5 = [Ovr_Tz5 Ovr(4)];
Ovr_Tz6 = [Ovr_Tz6 Ovr(5)];
Ovr_Tz7 = [Ovr_Tz7 Ovr(6)];
Ovr_Tz8 = [Ovr_Tz8 Ovr(7)];
Ovr_Tz9 = [Ovr_Tz9 Ovr(8)];
lineS3 =plot (Tz (1), Ovr(1), 'o', 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'g');
hold on
plot (Tz (2), Ovr(2), 'o', 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'g');
hold on
plot (Tz (3), Ovr(3), 'o', 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'g');
hold on
plot (Tz (4), Ovr(4), 'o', 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'g');
hold on
plot (Tz (5), Ovr(5), 'o', 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'g');
hold on
plot (Tz (6), Ovr(6), 'o', 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'g');
hold on
plot (Tz (7), Ovr(7), 'o', 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'g');
hold on
plot (Tz (8), Ovr(8), 'o', 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'g');
hold on


load 'Hs1_S4.mat';
Ovr_Tz2 = [Ovr_Tz2 Ovr(1)];
Ovr_Tz3 = [Ovr_Tz3 Ovr(2)];
Ovr_Tz4 = [Ovr_Tz4 Ovr(3)];
Ovr_Tz5 = [Ovr_Tz5 Ovr(4)];
Ovr_Tz6 = [Ovr_Tz6 Ovr(5)];
Ovr_Tz7 = [Ovr_Tz7 Ovr(6)];
Ovr_Tz8 = [Ovr_Tz8 Ovr(7)];
Ovr_Tz9 = [Ovr_Tz9 Ovr(8)];
lineS4 =plot (Tz (1), Ovr(1), 'o', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
hold on
plot (Tz (2), Ovr(2), 'o', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
hold on
plot (Tz (3), Ovr(3), 'o', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
hold on
plot (Tz (4), Ovr(4), 'o', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
hold on
plot (Tz (5), Ovr(5), 'o', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
hold on
plot (Tz (6), Ovr(6), 'o', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
hold on
plot (Tz (7), Ovr(7), 'o', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
hold on
plot (Tz (8), Ovr(8), 'o', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
hold on



load 'Hs1_S5.mat';
Ovr_Tz2 = [Ovr_Tz2 Ovr(1)];
Ovr_Tz3 = [Ovr_Tz3 Ovr(2)];
Ovr_Tz4 = [Ovr_Tz4 Ovr(3)];
Ovr_Tz5 = [Ovr_Tz5 Ovr(4)];
Ovr_Tz6 = [Ovr_Tz6 Ovr(5)];
Ovr_Tz7 = [Ovr_Tz7 Ovr(6)];
Ovr_Tz8 = [Ovr_Tz8 Ovr(7)];
Ovr_Tz9 = [Ovr_Tz9 Ovr(8)];
lineS5 =plot (Tz (1), Ovr(1), 'o', 'MarkerFaceColor', 'y', 'MarkerEdgeColor', 'y');
hold on
plot (Tz (2), Ovr(2), 'o', 'MarkerFaceColor', 'y', 'MarkerEdgeColor', 'y');
hold on
plot (Tz (3), Ovr(3), 'o', 'MarkerFaceColor', 'y', 'MarkerEdgeColor', 'y');
hold on
plot (Tz (4), Ovr(4), 'o', 'MarkerFaceColor', 'y', 'MarkerEdgeColor', 'y');
hold on
plot (Tz (5), Ovr(5), 'o', 'MarkerFaceColor', 'y', 'MarkerEdgeColor', 'y');
hold on
plot (Tz (6), Ovr(6), 'o', 'MarkerFaceColor', 'y', 'MarkerEdgeColor', 'y');
hold on
plot (Tz (7), Ovr(7), 'o', 'MarkerFaceColor', 'y', 'MarkerEdgeColor', 'y');
hold on
plot (Tz (8), Ovr(8), 'o', 'MarkerFaceColor', 'y', 'MarkerEdgeColor', 'y');
hold on


load 'Hs1_S6.mat';
Ovr_Tz2 = [Ovr_Tz2 Ovr(1)];
Ovr_Tz3 = [Ovr_Tz3 Ovr(2)];
Ovr_Tz4 = [Ovr_Tz4 Ovr(3)];
Ovr_Tz5 = [Ovr_Tz5 Ovr(4)];
Ovr_Tz6 = [Ovr_Tz6 Ovr(5)];
Ovr_Tz7 = [Ovr_Tz7 Ovr(6)];
Ovr_Tz8 = [Ovr_Tz8 Ovr(7)];
Ovr_Tz9 = [Ovr_Tz9 Ovr(8)];
lineS6 = plot (Tz (1), Ovr(1), 'o', 'MarkerFaceColor', 'c', 'MarkerEdgeColor', 'c');
hold on
plot (Tz (2), Ovr(2), 'o', 'MarkerFaceColor', 'c', 'MarkerEdgeColor', 'c');
hold on
plot (Tz (3), Ovr(3), 'o', 'MarkerFaceColor', 'c', 'MarkerEdgeColor', 'c');
hold on
plot (Tz (4), Ovr(4), 'o', 'MarkerFaceColor', 'c', 'MarkerEdgeColor', 'c');
hold on
plot (Tz (5), Ovr(5), 'o', 'MarkerFaceColor', 'c', 'MarkerEdgeColor', 'c');
hold on
plot (Tz (6), Ovr(6), 'o', 'MarkerFaceColor', 'c', 'MarkerEdgeColor', 'c');
hold on
plot (Tz (7), Ovr(7), 'o', 'MarkerFaceColor', 'c', 'MarkerEdgeColor', 'c');
hold on
plot (Tz (8), Ovr(8), 'o', 'MarkerFaceColor', 'c', 'MarkerEdgeColor', 'c');
hold on

meanOvr = [mean(Ovr_Tz2) mean(Ovr_Tz3) mean(Ovr_Tz4) mean(Ovr_Tz5) mean(Ovr_Tz6) mean(Ovr_Tz7) mean(Ovr_Tz8) mean(Ovr_Tz9)];
StdOvr = [std(Ovr_Tz2) std(Ovr_Tz3) std(Ovr_Tz4) std(Ovr_Tz5) std(Ovr_Tz6) std(Ovr_Tz7) std(Ovr_Tz8) std(Ovr_Tz9)];
errorbar (Tz, meanOvr, StdOvr, 'm')
clear all


subplot (2,2,2)
title('Windspeed 11.4 m/s, Significant wave height 5 m')
xlabel('Peak-spectral period [s]','FontSize',10);
ylabel('Overturning-Moment [Nm]','FontSize',10);
grid on
hold on
load 'Hs5_S1.mat';
Ovr_Tz2 = Ovr(1);
Ovr_Tz3 = Ovr(2);
Ovr_Tz4 = Ovr(3);
Ovr_Tz5 = Ovr(4);
Ovr_Tz6 = Ovr(5);
Ovr_Tz7 = Ovr(6);
Ovr_Tz8 = Ovr(7);
lineS1 = plot (Tz (1), Ovr(2), 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'r');
hold on
plot (Tz (2), Ovr(2), 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'r');
hold on
plot (Tz (3), Ovr(3), 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'r');
hold on
plot (Tz (4), Ovr(4), 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'r');
hold on
plot (Tz (5), Ovr(5), 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'r');
hold on
plot (Tz (6), Ovr(6), 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'r');
hold on
plot (Tz (7), Ovr(7), 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'r');
hold on


load 'Hs5_S2.mat';
Ovr_Tz2 = [Ovr_Tz2 Ovr(1)];
Ovr_Tz3 = [Ovr_Tz3 Ovr(2)];
Ovr_Tz4 = [Ovr_Tz4 Ovr(3)];
Ovr_Tz5 = [Ovr_Tz5 Ovr(4)];
Ovr_Tz6 = [Ovr_Tz6 Ovr(5)];
Ovr_Tz7 = [Ovr_Tz7 Ovr(6)];
Ovr_Tz8 = [Ovr_Tz8 Ovr(7)];
lineS2 =plot (Tz (1), Ovr(1), 'o', 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'b');
hold on
plot (Tz (2), Ovr(2), 'o', 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'b');
hold on
plot (Tz (3), Ovr(3), 'o', 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'b');
hold on
plot (Tz (4), Ovr(4), 'o', 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'b');
hold on
plot (Tz (5), Ovr(5), 'o', 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'b');
hold on
plot (Tz (6), Ovr(6), 'o', 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'b');
hold on
plot (Tz (7), Ovr(7), 'o', 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'b');
hold on


load 'Hs5_S3.mat';
Ovr_Tz2 = [Ovr_Tz2 Ovr(1)];
Ovr_Tz3 = [Ovr_Tz3 Ovr(2)];
Ovr_Tz4 = [Ovr_Tz4 Ovr(3)];
Ovr_Tz5 = [Ovr_Tz5 Ovr(4)];
Ovr_Tz6 = [Ovr_Tz6 Ovr(5)];
Ovr_Tz7 = [Ovr_Tz7 Ovr(6)];
Ovr_Tz8 = [Ovr_Tz8 Ovr(7)];
lineS3 =plot (Tz (1), Ovr(1), 'o', 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'g');
hold on
plot (Tz (2), Ovr(2), 'o', 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'g');
hold on
plot (Tz (3), Ovr(3), 'o', 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'g');
hold on
plot (Tz (4), Ovr(4), 'o', 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'g');
hold on
plot (Tz (5), Ovr(5), 'o', 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'g');
hold on
plot (Tz (6), Ovr(6), 'o', 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'g');
hold on
plot (Tz (7), Ovr(7), 'o', 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'g');
hold on


load 'Hs5_S4.mat';
Ovr_Tz2 = [Ovr_Tz2 Ovr(1)];
Ovr_Tz3 = [Ovr_Tz3 Ovr(2)];
Ovr_Tz4 = [Ovr_Tz4 Ovr(3)];
Ovr_Tz5 = [Ovr_Tz5 Ovr(4)];
Ovr_Tz6 = [Ovr_Tz6 Ovr(5)];
Ovr_Tz7 = [Ovr_Tz7 Ovr(6)];
Ovr_Tz8 = [Ovr_Tz8 Ovr(7)];
lineS4 =plot (Tz (1), Ovr(1), 'o', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
hold on
plot (Tz (2), Ovr(2), 'o', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
hold on
plot (Tz (3), Ovr(3), 'o', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
hold on
plot (Tz (4), Ovr(4), 'o', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
hold on
plot (Tz (5), Ovr(5), 'o', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
hold on
plot (Tz (6), Ovr(6), 'o', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
hold on
plot (Tz (7), Ovr(7), 'o', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
hold on


load 'Hs5_S5.mat';
Ovr_Tz2 = [Ovr_Tz2 Ovr(1)];
Ovr_Tz3 = [Ovr_Tz3 Ovr(2)];
Ovr_Tz4 = [Ovr_Tz4 Ovr(3)];
Ovr_Tz5 = [Ovr_Tz5 Ovr(4)];
Ovr_Tz6 = [Ovr_Tz6 Ovr(5)];
Ovr_Tz7 = [Ovr_Tz7 Ovr(6)];
Ovr_Tz8 = [Ovr_Tz8 Ovr(7)];
lineS5 =plot (Tz (1), Ovr(1), 'o', 'MarkerFaceColor', 'y', 'MarkerEdgeColor', 'y');
hold on
plot (Tz (2), Ovr(2), 'o', 'MarkerFaceColor', 'y', 'MarkerEdgeColor', 'y');
hold on
plot (Tz (3), Ovr(3), 'o', 'MarkerFaceColor', 'y', 'MarkerEdgeColor', 'y');
hold on
plot (Tz (4), Ovr(4), 'o', 'MarkerFaceColor', 'y', 'MarkerEdgeColor', 'y');
hold on
plot (Tz (5), Ovr(5), 'o', 'MarkerFaceColor', 'y', 'MarkerEdgeColor', 'y');
hold on
plot (Tz (6), Ovr(6), 'o', 'MarkerFaceColor', 'y', 'MarkerEdgeColor', 'y');
hold on
plot (Tz (7), Ovr(7), 'o', 'MarkerFaceColor', 'y', 'MarkerEdgeColor', 'y');
hold on



load 'Hs5_S6.mat';
Ovr_Tz2 = [Ovr_Tz2 Ovr(1)];
Ovr_Tz3 = [Ovr_Tz3 Ovr(2)];
Ovr_Tz4 = [Ovr_Tz4 Ovr(3)];
Ovr_Tz5 = [Ovr_Tz5 Ovr(4)];
Ovr_Tz6 = [Ovr_Tz6 Ovr(5)];
Ovr_Tz7 = [Ovr_Tz7 Ovr(6)];
Ovr_Tz8 = [Ovr_Tz8 Ovr(7)];
lineS6 = plot (Tz (1), Ovr(1), 'o', 'MarkerFaceColor', 'c', 'MarkerEdgeColor', 'c');
hold on
plot (Tz (2), Ovr(2), 'o', 'MarkerFaceColor', 'c', 'MarkerEdgeColor', 'c');
hold on
plot (Tz (3), Ovr(3), 'o', 'MarkerFaceColor', 'c', 'MarkerEdgeColor', 'c');
hold on
plot (Tz (4), Ovr(4), 'o', 'MarkerFaceColor', 'c', 'MarkerEdgeColor', 'c');
hold on
plot (Tz (5), Ovr(5), 'o', 'MarkerFaceColor', 'c', 'MarkerEdgeColor', 'c');
hold on
plot (Tz (6), Ovr(6), 'o', 'MarkerFaceColor', 'c', 'MarkerEdgeColor', 'c');
hold on
plot (Tz (7), Ovr(7), 'o', 'MarkerFaceColor', 'c', 'MarkerEdgeColor', 'c');
hold on


meanOvr = [mean(Ovr_Tz2) mean(Ovr_Tz3) mean(Ovr_Tz4) mean(Ovr_Tz5) mean(Ovr_Tz6) mean(Ovr_Tz7) mean(Ovr_Tz8)];
StdOvr = [std(Ovr_Tz2) std(Ovr_Tz3) std(Ovr_Tz4) std(Ovr_Tz5) std(Ovr_Tz6) std(Ovr_Tz7) std(Ovr_Tz8)];
errorbar (Tz, meanOvr, StdOvr, 'm')




subplot (2,2,3)
title('Windspeed 35 m/s, Significant wave height 10 m')
xlabel('Peak-spectral period [s]','FontSize',10);
ylabel('Overturning-Moment [Nm]','FontSize',10);
grid on
hold on


L = legend([lineS1, lineS2, lineS3, lineS4, lineS5, lineS6],{'Seed 1','seed 2','Seed 3','Seed 4','Seed 5','Seed 6'});
set(L,'Position', [0.6, 0.1, 0.2, 0.25])
