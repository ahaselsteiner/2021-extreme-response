function s = medianSteepnessAtV(v)
    %s = 0.043 - 0.037 * exp(-0.11 * v);
    s = 0.012 + 0.021 ./ (1 + exp(-0.3*(v - 10)));
end
