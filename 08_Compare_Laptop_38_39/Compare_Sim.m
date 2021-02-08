a = abs(Flp1_39)-abs(Flp1_my);
b = abs(Flp1_38)-abs(Flp1_my);

figure ('Position', [10 100 1250 500]),
subplot (3,1,1)
plot (Time, Flp1_my, 'b');
hold on
plot (Time, Flp1_38, ':g');
hold on
plot (Time, Flp1_39, ':r');
hold on
xlabel('Time [s]','FontSize',10);
ylabel('Flp-Moment','FontSize',10);
hold on
legend('Flp Laptop', 'Flp PC38', 'Flp PC39')
grid on
hold on
subplot (3,1,2)
plot (Time, b, 'g');
xlabel('Time [s]','FontSize',10);
ylabel('Diff. Flp PC38 - laptop','FontSize',10);
subplot (3,1,3)
plot (Time, a, 'r');
xlabel('Time [s]','FontSize',10);
ylabel('Diff. Flp PC39 - laptop','FontSize',10);


% Diff = max(a);
% k = find(a==Diff);
% Flp1_nc(k)
% c = (100/Flp1_nc(k));

