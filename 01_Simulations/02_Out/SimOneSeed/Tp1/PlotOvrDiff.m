Ovr = sqrt(ReactMXss.^2 +ReactMYss.^2);

Ovr1 = sqrt(ReactMXss1.^2 +ReactMYss1.^2);

subplot (3,1,1)
plot(Time, Ovr);
hold on
title ('Simulation with v = 0,00001 m/s');
xlabel('Wind Speed [m/s]','FontSize',10);
ylabel('Ovr [Nm]','FontSize',10);
axis([0 3630 0 17*10^7]);

subplot (3,1,2)
plot(Time, Ovr1);
hold on
title ('Simulation without InflowWind, AeroDyn and Blade-BeamDyn');
xlabel('Wind Speed [m/s]','FontSize',10);
ylabel('Ovr [Nm]','FontSize',10);
axis([0 3630 0 17*10^7]);


OvrDiff = Ovr1 - Ovr;

subplot (3,1,3)
plot(Time, OvrDiff);
hold on
title ('Difference simulations');
xlabel('Wind Speed [m/s]','FontSize',10);
ylabel('Ovr [Nm]','FontSize',10);
axis([0 3630 -17*10^7 17*10^7]);