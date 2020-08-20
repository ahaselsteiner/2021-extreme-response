%Values for maximum flapwise moment, edgewise moment and overturning moment

Bld1 = [];
Bld2 = [];
Bld3 = [];

Flp1 = [];
Flp2 = [];
Flp3 = [];

Edg1 = [];
Edg2 = [];
Edg3 = [];

Ovr = [];

load 'values_seed_1'; %values_S1, values_S2, values_S3, values_S4, values_S5 oder values_S6

v = [26 30:5:80];         %[3 :2 :25];

max_Flp1 = max(RootMFlp1); %Max flapwise moment blade 1
max_Flp2 = max(RootMFlp2); %Max flapwise moment blade 2
max_Flp3 = max(RootMFlp3); %Max flapwise moment blade 3
 
min_Flp1 = min(RootMFlp1); %Min flapwise moment blade 1
min_Flp2 = min(RootMFlp2); %Min flapwise moment blade 2
min_Flp3 = min(RootMFlp3); %Min flapwise moment blade 3

max_Edg1 = max(RootMEdg1); %Max edgewise moment blade 1
max_Edg2 = max(RootMEdg2); %Max edgewise moment blade 2
max_Edg3 = max(RootMEdg3); %Max edgewise moment blade 3

min_Edg1 = min(RootMEdg1); %Min edgewise moment blade 1
min_Edg2 = min(RootMEdg2); %Min edgewise moment blade 2
min_Edg3 = min(RootMEdg3); %Min edgewise moment blade 3
 
if abs(max_Flp1) > abs(min_Flp1)
    a = abs(max_Flp1);
else
    a = abs(min_Flp1);
end

if abs(max_Flp2) > abs(min_Flp2)
    b = abs(max_Flp2);
else
    b = abs(min_Flp2);
end

if abs(max_Flp3) > abs(min_Flp3)
    c = abs(max_Flp3);
else
    c = abs(min_Flp3);
end

Flp1 = [Flp1 a]; % Flp1
Flp2 = [Flp2 b]; % Flp2
Flp3 = [Flp3 c]; % Flp3


if abs(max_Edg1) > abs(min_Edg1)
    d = abs(max_Edg1);
else
    d = abs(min_Edg1);
end

if abs(max_Edg2) > abs(min_Edg2)
    e = abs(max_Edg2);
else
    e = abs(min_Edg2);
end

if abs(max_Edg3) > abs(min_Edg3)
    f = abs(max_Edg3);
else
    f = abs(min_Edg3);
end

Edg1 = [Edg1 d]; % Edg1
Edg2 = [Edg2 e]; % Edg2
Edg3 = [Edg3 f]; % Edg3

OvrM = sqrt(ReactMXss.^2 + ReactMYss.^2);
Ovr = [Ovr max(OvrM)]; %Ovr 

g = sqrt(RootMFlp1.^2 + RootMEdg1.^2);
h = sqrt(RootMFlp2.^2 + RootMEdg2.^2);
k = sqrt(RootMFlp3.^2 + RootMEdg3.^2);

Bld1 = [Bld1 max(g)]; 
Bld2 = [Bld2 max(h)];
Bld3 = [Bld3 max(k)];

save('values_seed_1.mat','Flp1','Flp2','Flp3','Edg1','Edg2','Edg3', 'Bld1','Bld2','Bld3','Ovr', 'v');