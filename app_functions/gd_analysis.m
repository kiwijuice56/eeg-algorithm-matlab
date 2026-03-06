function [mci_scores] = gd_analysis(eeg_rest, fnirs_rest, eeg_40_assr, fnirs_40_assr)
%GD_ASSR_ANALYSIS Summary of this function goes here
%   Detailed explanation goes here
arguments (Input)
    eeg_rest    (8,:) double
    fnirs_rest  (8,:) double
    eeg_40_assr    (8,:) double
    fnirs_40_assr  (8,:) double
end

arguments (Output)
    mci_scores (1,:) double
end

% Preprocess long trial data
p_eeg_rest = preprocess_eeg(eeg_rest);
p_fnirs_rest = preprocess(fnirs_rest);

p_eeg_40_assr = preprocess_eeg(eeg_40_assr);
p_fnirs_40_assr = preprocess(fnirs_40_assr);

[score, power_rest, power_assr] = assr_analysis( ...
    p_eeg_rest, p_fnirs_rest, ...
    p_eeg_40_assr, p_fnirs_40_assr);

% TODO: replace the power with other scores
mci_scores = [score, power_rest, power_assr];

end