%Flapwise-Moment Blade 1 ==> RootMFlp1
figure
subplot (5,1,1), plot (Time, RootMFlp1, 'Linewidth', 1);
xlabel('Time [s]','FontSize',10);
ylabel('Flapwise-Moment','FontSize',10);
grid on

%Edgewise-Moment Blade 1 ==> RootMEdg1
subplot (5,1,2), plot (Time, RootMEdg1, 'Linewidth', 1);
xlabel('Time [s]','FontSize',10);
ylabel('Edgewise-Moment','FontSize',10);
grid on

%Overturning Moment
QReactMX = ReactMXss.*ReactMXss;            
QReactMY = ReactMYss.*ReactMYss;           
OvrTrngM =sqrt(QReactMX+QReactMY);
subplot (5,1,3), plot (Time, OvrTrngM, 'Linewidth', 1);
xlabel('Time [s]','FontSize',10);
ylabel('Overturning Moment','FontSize',10);
grid on

% Pitch Blade 1 ==> BiPitch
subplot (5,1,4), plot (Time, B1Pitch, 'Linewidth', 1);
xlabel('Time [s]','FontSize',10);
ylabel('Pitch','FontSize',10);
grid on

% %Water Lavel
subplot (5,1,5), plot (Time, Wave1Elev, 'Linewidth', 1);
xlabel('Time [s]','FontSize',10);
ylabel('Wasseroberfläche[m]','FontSize',10);
grid on





