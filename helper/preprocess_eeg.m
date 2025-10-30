function [processed_eeg_struct] = preprocess_eeg(eeg_struct)
%PREPROCESS_EEG Preprocess a struct of EEG data as returned from
% read_from_json_file_raw.
%
% Input:
%   eeg_struct - struct, each field is a channel (e.g., eeg0, eeg1, ...),
%                containing .time (nx1) and .data (nx1)
%
% Output:
%   processed_eeg_struct - struct, each field is a channel (e.g., eeg0, eeg1, ...),
%                          containing .time (nx1) and .data (nx1)
arguments (Input)
    eeg_struct
end

arguments (Output)
    processed_eeg_struct
end

Fs = 256;

% TODO: finish this
processed_eeg_struct = eeg_struct;

end