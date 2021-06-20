v = [11, 17, 35];           %windspeed
hs = [0, 5, 11, 13];        %wave height
tp = [2, 3];                %spectral period index
k = [1:9];                  %node on monipile


windspeed   = 11;
waveheight  = 0;
tpindex     =  2;

a = find(v==windspeed);
b = find(hs==waveheight);
c = find(tp==tpindex);

w = squeeze(Ovr(a,b,c,:));

f1 = figure;
s = [];

for i=1:9
    s = [s max(Dyn(a,b,c,i,:));];
end

t = [s 0];

yyaxis left
X = categorical({'Node 1', 'Node 2', 'Node 3', 'Node 4', 'Node 5', 'Node 6', 'Node 7', 'Node 8', 'Node 9', 'Ovr'});
X = reordercats(X,{'Node 1', 'Node 2', 'Node 3', 'Node 4', 'Node 5', 'Node 6', 'Node 7', 'Node 8', 'Node 9', 'Ovr'});
bar(X,t);
ylabel('Dynamic Moment [Nm]');

yyaxis right
u = [0 0 0 0 0 0 0 0 0  max(w)];
bar(u);
ylabel('Overturning-Moment [Nm]');

title(['Dynamic Moment for v = ', num2str(windspeed), ' m/s; hs = ', num2str(waveheight), ' m; tp index = ', num2str(tpindex)]); 


f2 = figure;
s = [];

for i=1:9
    s = [s max(Stat(a,b,c,i,:));];
end

t = [s 0];

yyaxis left
X = categorical({'Node 1', 'Node 2', 'Node 3', 'Node 4', 'Node 5', 'Node 6', 'Node 7', 'Node 8', 'Node 9', 'Ovr'});
X = reordercats(X,{'Node 1', 'Node 2', 'Node 3', 'Node 4', 'Node 5', 'Node 6', 'Node 7', 'Node 8', 'Node 9', 'Ovr'});
bar(X,t);
ylabel('Static Moment [Nm]');

yyaxis right
u = [0 0 0 0 0 0 0 0 0  max(w)];
bar(u);
ylabel('Overturning-Moment [Nm]');

title(['Static Moment for v = ', num2str(windspeed), ' m/s; hs = ', num2str(waveheight), ' m; tp index = ', num2str(tpindex)]); 


