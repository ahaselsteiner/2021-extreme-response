function s = maxSteepnessAtV(v)
  s = (v <= 19) .* (0.021 + (0.054 - 0.021) / 19 * v) + (v > 19) .* 0.054;
end
