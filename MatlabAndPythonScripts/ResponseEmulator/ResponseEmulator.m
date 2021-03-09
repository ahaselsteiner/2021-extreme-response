classdef ResponseEmulator
    %RESPONSEEMULATOR Emulates the overturning moment of a wind turbine
    %   Detailed explanation goes here
    
    properties
        % Prameters of a GEV that describes 1-minute maxima of the over
        % turning moment.
        %k = -0.2
        %k = @(v1hr) (v1hr < 16.5) .* -0.2 + (v1hr >= 16.5) .* 0
        %k = @(v1hr) (v1hr <= 13) .* -0.2 + (v1hr > 13 & v1hr < 17) .* (-0.2 + (v1hr - 13) * 0.05) + (v1hr >= 17) .* 0
        k = @(v1hr) -0.1
        % The first guestimates.
%         sigma = @(v1hr, hs, tp) 0 + (tp >= sqrt(2 * pi .* hs ./ (9.81 .* 1/14.99))) .* ...
%             (5.0e+03 .* v1hr.^2 + (v1hr <= 25) .* (1.4e+06 .* v1hr -  5.3e+04 .* v1hr.^2) + ...
%             1.7e+06  .* hs ./ (1 + 0.05 .* (tp - 3)))
%         mu = @(v1hr, hs, tp) 0 + (tp >= sqrt(2 * pi .* hs ./ (9.81 .* 1/14.99))) .* ...
%             (3.3e+04 .* v1hr.^2 + (v1hr <= 25) .* (8e+06 .* v1hr -  2.5e+05 .* v1hr.^2) + ...
%             3.2e+06  .* hs ./ (1 + 0.05 .* (tp - 3)))
        
        % Based on openFAST simulations.
        sigma = @(v1hr, hs, tp) 0 + (tp >= sqrt(2 * pi .* hs ./ (9.81 .* 1/14.99))) .* ...
            ((((v1hr <= 25) .* (1.3037e+05 .* v1hr + 2.5706e+07 ./ (1 + 0.064 * (v1hr - 11.6).^2) +  -1.9272e+07 ./ (1 + 0.2 * (v1hr - 11.6).^2)) + ...
            (v1hr > 25) .* 4400 .* v1hr.^2).^2.0 + ...
            ((1 + (v1hr > 25) * 0.2) .* 2.086e+06 .* hs.^1.0 .* (1 + 0.3 ./ (1 + 5 .* (tp - 3).^2))).^2.0).^(1/2.0));
        mu = @(v1hr, hs, tp) (tp >= sqrt(2 * pi .* hs ./ (9.81 .* 1/14.99))) .* ...
            ((((v1hr <= 25) .* 3.1733e+06 .* v1hr + 7.0903e+07  ./ (1 + 0.060357   * (v1hr - 11.6).^2) + ... %min([(v1hr <= 25) .* 9.5 * 10^7], [3.2278e+06 .* v1hr + 8.5947e+07  ./ (1 + 0.089499  * (v1hr - 11.6).^2)]) + ...
            (v1hr > 25 ) .* (3.65 * 10^4  .* v1hr.^2)).^2.0 + ...
            ((1 + (v1hr > 25) * 0.2) .* 9.942e+06 .* hs.^1.0 .* (1 + 0.3 ./ (1 + 5 .* (tp - 3).^2))).^2.0).^(1/2.0));
        
        maxima_per_hour = 60;
        tpbreaking = @(hs) sqrt(2 * pi * hs / (9.81 * 1/15));
        tpSteepness = @(hs, steepness) sqrt(2 * pi * hs / (9.81 * steepness))
        tp = @(hs, idx) (idx == 1) .* sqrt(2 * pi * hs / (9.81 * 1/15)) + ...
            (idx == 2) .* sqrt(2 * pi * hs / (9.81 * 1/20)) + ...
            (idx == 3) .* (sqrt(2 * pi * hs / (9.81 * 1/20)) + 1 ./ (1 + sqrt(hs + 2)) * 8) + ...
            (idx == 4) .* (sqrt(2 * pi * hs / (9.81 * 1/20)) + 1 ./ (1 + sqrt(hs + 2)) * 20);
    end
    
    methods
        function p = CDF1min(obj, v1hr, hs, tp, r)
            pd = makedist('GeneralizedExtremeValue', 'k', obj.k(v1hr), 'sigma', obj.sigma(v1hr,hs,tp), 'mu', obj.mu(v1hr,hs,tp));
            p = pd.cdf(r);
        end
        
        function p = CDF1hr(obj, v1hr, hs, tp, r)
            pd = makedist('GeneralizedExtremeValue', 'k', obj.k(v1hr), 'sigma', obj.sigma(v1hr,hs,tp), 'mu', obj.mu(v1hr,hs,tp));
            p = pd.cdf(r).^obj.maxima_per_hour;
        end
        
        function r = ICDF1min(obj, v1hr, hs, tp, p)
            pd = makedist('GeneralizedExtremeValue','k', obj.k(v1hr), 'sigma', obj.sigma(v1hr,hs,tp), 'mu', obj.mu(v1hr,hs,tp));
            r = pd.icdf(p);
        end
        
        function r = ICDF1hr(obj, v1hr, hs, tp, p)
            r = nan(size(v1hr));
            for i = 1 : size(v1hr,  1)
                for j = 1 : size(v1hr,  2)
                    for kk = 1 : size(v1hr,  3)
                        s = obj.sigma(v1hr(i,j,kk),hs(i,j,kk),tp(i,j,kk));
                        m = obj.mu(v1hr(i,j,kk),hs(i,j,kk),tp(i,j,kk));
                        shapek = obj.k(v1hr(i,j,kk));
                        pd = makedist('GeneralizedExtremeValue','k', shapek, 'sigma', s, 'mu', m);
                        if length(p) == 1
                            r(i,j,kk) = pd.icdf(p.^(1/obj.maxima_per_hour));
                        else
                            r(i,j,kk) = pd.icdf(p(i,j,kk).^(1/obj.maxima_per_hour));
                        end
                    end
                end
            end
        end
        
        function r = randomSample1hr(obj, v1hr, hs, tp, n)
            p = rand(n, 1);
            r = nan(n, 1);
            for i = 1 : n
                r(i) = obj.ICDF1hr(v1hr, hs, tp, p(i));
            end
        end
        
        function f = PDF1hr(obj, v1hr, hs, tp, r)
            pd = makedist('GeneralizedExtremeValue', 'k', obj.k(v1hr), 'sigma', obj.sigma(v1hr,hs,tp), 'mu', obj.mu(v1hr,hs,tp));
            f = 60 .* pd.cdf(r).^59 .* pd.pdf(r);
        end
    end
end

