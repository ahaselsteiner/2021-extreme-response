classdef ResponseEmulator
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        k = -0.1
        sigma = @(v1hr, hs, tp) 2.1e+03 .* v1hr.^2 + (v1hr <= 25) .* (1.4e+06 .* v1hr -  5.3e+04 .* v1hr.^2) + 1.7e+06  .* hs ./ (1 + 0.05 .* (tp - 3))
        mu = @(v1hr, hs, tp) 3e+04 .* v1hr.^2 + (v1hr <= 25) .* (8e+06 .* v1hr -  2.5e+05 .* v1hr.^2) + 3.2e+06  .* hs ./ (1 + 0.05 .* (tp - 3))
        maxima_per_hour = 60;
        
    end
    
    methods
        function p = CDF1min(obj, v1hr, hs, tp, r)
            pd = makedist('GeneralizedExtremeValue','k', obj.k,'sigma', obj.sigma(v1hr,hs,tp),'mu', obj.mu(v1hr,hs,tp));
            p = pd.cdf(r);
        end
        
        function p = CDF1hr(obj, v1hr, hs, tp, r)
            pd = makedist('GeneralizedExtremeValue','k', obj.k,'sigma', obj.sigma(v1hr,hs,tp),'mu', obj.mu(v1hr,hs,tp));
            p = pd.cdf(r).^obj.maxima_per_hour;
        end
        
        function r = ICDF1min(obj, v1hr, hs, tp, p)
            pd = makedist('GeneralizedExtremeValue','k', obj.k,'sigma', obj.sigma(v1hr,hs,tp),'mu', obj.mu(v1hr,hs,tp));
            r = pd.icdf(p);
        end
        
        function r = ICDF1hr(obj, v1hr, hs, tp, p)
            pd = makedist('GeneralizedExtremeValue','k', obj.k,'sigma', obj.sigma(v1hr,hs,tp),'mu', obj.mu(v1hr,hs,tp));
            r = pd.icdf(p.^(1/obj.maxima_per_hour));
        end
    end
end

