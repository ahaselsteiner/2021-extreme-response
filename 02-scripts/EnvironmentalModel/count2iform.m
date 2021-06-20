function [xcont,ycont] = count2iform(x, y, fxy, alpha, angleStep)
% COUNT2IFORM computes an IFORM contour
%	Inputs: 
%   x - x-values where the density function is evaluated.
%   y - y-values where the density function is evaluated.
%   fxy - Density function at x,y.
%   alpha - Contour's exceedance probability.
%   angleStep - Resolution at which the contour should be computed in deg.

% Conditional CDF of y given x.
CDFygx = cumsum(fxy, 1);
m = repmat(CDFygx(end, :), length(y), 1);
CDFygx = CDFygx ./ m;
bad = sum(isnan(CDFygx), 1) > 0;
i0 = find(bad == 0, 1, 'first');
i1 = find(bad(i0 : end) == 1, 1, 'first') + i0-2;
if isempty(i1)
    i1 = length(x);
end
CDFygx = CDFygx(:, i0 : i1);
xi = x(i0 : i1);

% CDF of x.
CDFx = sum(cumsum(fxy, 2), 1);
CDFx = CDFx / max(CDFx);

% Contour points in normal space.
r = norminv(1 - alpha);
theta = (0 : angleStep : 360) * pi / 180;
ux = r * cos(theta);
uy = r * sin(theta);
Px = normcdf(ux);
Py = normcdf(uy);

% Contour points on original margins.
[CDFx, inds] = unique(CDFx);
xcont = interp1(CDFx, x(inds), Px, 'pchip');

ycont = 0 * xcont;
for i = 1 : length(uy)
    if xcont(i) < min(xi)
        condCDFy = CDFygx(:,1);
    else
        condCDFy = interp2(xi,y,CDFygx,xcont(i),y);
    end
    i0 = find(condCDFy < Py(i), 1 , 'last');
    i1 = find(condCDFy > Py(i), 1, 'first');
    if isempty(i0) 
        i0 = 1;
    end
    if isempty(i1)
        disp('err')
    end
    if i1 == i0
        ycont(i) = y(i0);
    else
        ycont(i) = interp1(condCDFy(i0 : i1), y(i0 : i1), Py(i));
    end
end
