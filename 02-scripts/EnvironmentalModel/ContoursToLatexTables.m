
load('iform_2d_mediansteepness.csv')
IFORM_median.v = iform_2d_mediansteepness(:,1);
IFORM_median.hs = iform_2d_mediansteepness(:,2);
IFORM_median.tp = iform_2d_mediansteepness(:,3);
load('iform_2d_maxsteepness.csv')
IFORM_maxsteep.v = iform_2d_maxsteepness(:,1);
IFORM_maxsteep.hs = iform_2d_maxsteepness(:,2);
IFORM_maxsteep.tp = iform_2d_maxsteepness(:,3);

load('hdc_2d_mediansteepness.csv')
HDC2d_median.v = hdc_2d_mediansteepness(:,1);
HDC2d_median.hs = hdc_2d_mediansteepness(:,2);
HDC2d_median.tp = hdc_2d_mediansteepness(:,3);
load('hdc_2d_maxsteepness.csv')
HDC2d_maxsteep.v = hdc_2d_maxsteepness(:,1);
HDC2d_maxsteep.hs = hdc_2d_maxsteepness(:,2);
HDC2d_maxsteep.tp = hdc_2d_maxsteepness(:,3);

t_IFORM = table(IFORM_median.v, round(IFORM_median.hs, 2), round(IFORM_median.tp, 2), round(IFORM_maxsteep.tp, 2));
t_HDC = table(HDC2d_median.v, round(HDC2d_median.hs, 2), round(HDC2d_median.tp, 2), round(HDC2d_maxsteep.tp, 2));

table2latex(t_IFORM, 'Data/IFORM2d.tex')
table2latex(t_HDC, 'Data/HDC2d.tex')