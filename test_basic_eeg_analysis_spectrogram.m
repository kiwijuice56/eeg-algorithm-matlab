% Read data
signals = read_from_json_file("data/eric_alfaro/eyes_closed_4.json");
signal = signals.notch_filtered_eeg1.value;
Fs = 256; 

% Detrend and remove DC
signal = detrend(signal);
signal = highpass(signal, 1, Fs);

% Parameters
window = 256; % Length of each segment in samples
noverlap = 128; % Overlap between segments
nfft = 512; % Number of FFT points

spectrogram(signal, hanning(window), noverlap, nfft, Fs, 'yaxis');
title('EEG Spectrogram (left ear)');
ylim([0 60]); % Only show up to 60 Hz
clim([-40 60]);  % Tweak until bands are visible