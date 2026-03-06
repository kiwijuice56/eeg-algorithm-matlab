function [score, power_rest, power_assr] = assr_analysis(p_eeg_rest, p_fnirs_rest, p_eeg_40_assr, p_fnirs_40_assr)
arguments (Input)
    p_eeg_rest      (:,8) double
    p_fnirs_rest    (:,8) double
    p_eeg_40_assr   (:,8) double
    p_fnirs_40_assr (:,8) double
end

arguments (Output)
    score      (1,1) double
    power_rest (1,1) double
    power_assr (1,1) double
end



end