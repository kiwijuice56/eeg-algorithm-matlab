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

% Create EEGLab struct
EEG = eeg_emptyset;
EEG.data = [eeg_struct.eeg.data(1:4,:)];
EEG.nbchan = 4;
EEG.pnts = length(eeg_struct.eeg.time);
EEG.trials = 1;
EEG.srate = Fs;
EEG.times = (0 : length(signals.eeg.time) - 1) / Fs;
EEG = eeg_checkset(EEG);

% Rereference
EEG = pop_reref(EEG, []);


end