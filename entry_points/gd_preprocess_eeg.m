function [preprocessed_eeg_matrix] = gd_preprocess_eeg(eeg_matrix)
%GD_PREPROCESS_EEG 
arguments (Input)
    eeg_matrix (8,:) double
end

arguments (Output)
    preprocessed_eeg_matrix (8,:) double
end

% TODO: finish this
junk_struct.eeg.data = [700, 700, 700; 700, 700, 700; 700, 700, 700; 700, 700, 700];
junk_struct.eeg.time = [1, 2, 3];
preprocess_eeg(junk_struct)

preprocessed_eeg_matrix = eeg_matrix;

end