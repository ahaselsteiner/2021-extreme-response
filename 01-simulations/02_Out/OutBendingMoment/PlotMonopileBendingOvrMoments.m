v = [11, 17, 35];           %windspeed
hs = [0, 5, 11, 13];        %wave height
tp = [2, 3];                %spectral period index
k = [1:9];                  %node on monipile

% Dyn = zeros(numel(v), numel(hs), numel(tp), numel(k), 288001);
% Stat = zeros(numel(v), numel(hs), numel(tp), numel(k), 288001);
% Ovr= zeros(numel(v), numel(hs), numel(tp), 288001);

windspeed   = 11;
waveheight  = 0;
tpindex     = 2;

a = find(v==windspeed);
b = find(hs==waveheight);
c = find(tp==tpindex);

subplot(2,1,1);
plot(Time,s);
hold on
plot(Time, r, '--');
legend('Tower Base Moment','Static Moment');
ylabel('Moment [Nm]');
xlabel ('Time [s]');
title(['v = ', num2str(windspeed), ' m/s; hs = ', num2str(waveheight), ' m; tp index = ', num2str(tpindex)]); 

Diff = r - s;
subplot(2,1,2);
plot(Time, Diff);
ylabel('Moment [Nm]');
xlabel ('Time [s]');
