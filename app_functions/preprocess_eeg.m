function [preprocessed_eeg_matrix] = preprocess_eeg(eeg_matrix)
arguments (Input)
    eeg_matrix (8,:) double
end

arguments (Output)
    preprocessed_eeg_matrix (:,8) double
end

powerline_frequency = 60;
fs = 256;

% Processing in column-major order is faster, but we collect
% in row-major due to Muse packet handling
eeg_matrix = eeg_matrix';

% Restrict to relevant ranges:
bp_order = 4;  % 4th order Butterworth (applied fwd+reverse = effective 8th order)
[b_bp, a_bp] = butter(bp_order, [0.5 100] / (fs/2), 'bandpass');
preprocessed_eeg_matrix = filtfilt(b_bp, a_bp, eeg_matrix);  % zero-phase filtering

% Remove powerline noise:
notch_freq = powerline_frequency;
notch_bw   = 2; % Hz
[b_n, a_n] = butter(2, [(notch_freq - notch_bw/2), (notch_freq + notch_bw/2)] / (fs/2), 'stop');
preprocessed_eeg_matrix = filtfilt(b_n, a_n, preprocessed_eeg_matrix);

end