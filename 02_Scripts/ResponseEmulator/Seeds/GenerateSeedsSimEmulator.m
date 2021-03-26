% Seeds for sim emulator

v = [0, 1:2:25, 26, 30, 35, 40, 45];
hs = [0 1:2:15];
tp = [1:4];


Seeds= zeros(19, 9, 4, 4);

% 1. dimension = wind, 2. dimension = hs, 3. dimension = tp, 4. dimension =
% seed (1: first windseed, 2: second windseed, 3: first waveseed, 4: second waveseed)

% Generate random seeds

for i=1:19
    for j=1:9
        for k=1:4
            for m=1:4
                Seeds(i,j,k,m)=randi([-2147483648 2147483648],1);
            end
        end
    end
end

%Delete non-physical condistions

for n=1:4
    for o=2:6
        Seeds(o, 6, n, :) = NaN;
    end
    for p=2:9
        Seeds(p, 7, n, :) = NaN;
    end
    for q=2:11
        for r=8:9
            Seeds(q, r, n, :) = NaN;
        end
    end
end

save('SeedsEmulator.mat','Seeds');





