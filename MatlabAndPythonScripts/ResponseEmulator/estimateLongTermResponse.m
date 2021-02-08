load('D.mat');

half_year = 365/2 * 24;

t = D.t(half_year : end);
v1hr = D.V1hr(half_year : end);
hs = D.Hs(half_year : end);
tz = D.Tz(half_year : end);
tp = 1.2796 * tz; % Assuming a JONSWAP spectrum with gamma = 3.3

R = ResponseEmulator;
n = 1000;
p = rand(n, 1);
r = R.ICDF1hr(v1hr(1:n), hs(1:n), tp(1:n), p);

figure
yyaxis left 
plot(t(1:n), r);
ylabel('Overturning moment (Nm)')
yyaxis right 
plot(t(1:n), v1hr(1:n));
ylabel('1-hr wind speed (m/s)')


n = length(t);
p = rand(n, 1);
r = R.ICDF1hr(v1hr(1:n), hs(1:n), tp(1:n), p);

block_length = 365.25 * 24;
full_years = floor(n / block_length);
pds = [];
maxima = zeros(full_years, 1);
blocks = zeros(full_years, block_length);
block_maxima = zeros(full_years, 1);
block_max_i = zeros(full_years, 1);
for i = 1 : full_years
    blocks(i,:) = r((i - 1) * block_length + 1 : i * block_length);
    [block_maxima(i), maxid] = max(blocks(i,:));
    block_max_i(i) = maxid + (i - 1) * block_length;
end

figure()
subplot(2, 1, 1)
hold on
yyaxis left 
plot(t(1:n), r);
plot(t(block_max_i), r(block_max_i), 'xr');
ylabel('Overturning moment (Nm)')
yyaxis right 
plot(t(1:n), v1hr(1:n));
ylabel('1-hr wind speed (m/s)') 
xlabel('Time (s)');
subplot(2, 1, 2)
pd = fitdist(block_maxima, 'GeneralizedExtremeValue');
qqplot(block_maxima, pd)

x1_am = pd.icdf(exp(-1));
x50_am = pd.icdf(1 - 1/50);





