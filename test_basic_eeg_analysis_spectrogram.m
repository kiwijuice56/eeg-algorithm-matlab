% Read data
signals_eyes_open = read_from_json_file("data/eric_alfaro/eyes_open_1.json");
signals_eyes_closed = read_from_json_file("data/eric_alfaro/eyes_closed_1.json");

Fs = 1000; % sampling frequency in Hz

% Parameters
window = 64; % length of each segment in samples
noverlap = 32; % overlap between segments
nfft = 512; % number of FFT points

spectrogram(signals_eyes_open.eeg1.value, hanning(window), noverlap, nfft, Fs, 'yaxis');
title('EEG Spectrogram (left forehead)');