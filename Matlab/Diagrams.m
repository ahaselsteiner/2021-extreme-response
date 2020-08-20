%Flapwise-Moment Blade 1 ==> RootMFlp1
figure ('Position', [25 25 1500 750]),
subplot (3,1,1), plot (Time, RootMFlp1, 'Linewidth', 1);
xlabel('Time [s]','FontSize',10);
ylabel('Flapwise-Moment','FontSize',10);
grid on

%Edgewise-Moment Blade 1 ==> RootMEdg1
subplot (3,1,2), plot (Time, RootMEdg1, 'Linewidth', 1);
xlabel('Time [s]','FontSize',10);
ylabel('Edgewise-Moment','FontSize',10);
grid on

%Overturning Moment
QReactMX = ReactMXss.*ReactMXss;            
QReactMY = ReactMYss.*ReactMYss;           
OvrTrngM =sqrt(QReactMX+QReactMY);
subplot (3,1,3), plot (Time, OvrTrngM, 'Linewidth', 1);
xlabel('Time [s]','FontSize',10);
ylabel('Overturning Moment','FontSize',10);
grid on

% % Pitch Blade 1 ==> BiPitch
% subplot (6,1,4), plot (Time, B1Pitch, 'Linewidth', 1);
% xlabel('Time [s]','FontSize',10);
% ylabel('Pitch','FontSize',10);
% grid on

% %Water Lavel
% subplot (6,1,5), plot (Time, Wave1Elev, 'Linewidth', 1);
% xlabel('Time [s]','FontSize',10);
% ylabel('Waterlevel[m]','FontSize',10);
% grid on

% % Wind Speed
% WindSpeed = sqrt(Wind1VelX.^2 + Wind1VelY.^2 + Wind1VelZ.^2);
% subplot (4,1,4), plot (Time, WindSpeed, 'Linewidth', 1);
% xlabel('Time [s]','FontSize',10);
% ylabel('Windspeed [m*s^-1]','FontSize',10);
% grid on
% % 
% % Rotorspeed
% subplot (6,1,5), plot (Time, RtSpeed, 'Linewidth', 1);
% xlabel('Time [s]','FontSize',10);
% ylabel('Rotorspeed','FontSize',10);
% grid on


