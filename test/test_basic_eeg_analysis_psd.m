% Read data
signals_closed = read_from_json_file("data/eric_alfaro/eyes_closed_old_2.json");
signal_closed = signals_closed.notch_filtered_eeg2.value;

signals_open = read_from_json_file("data/eric_alfaro/eyes_open_old_1.json");
signal_open = signals_open.notch_filtered_eeg2.value;


% plot(signals_open.notch_filtered_eeg1.value);
Fs = 256; 

% Remove DC and drift
signal_closed = detrend(signal_closed);
signal_closed = bandpass(signal_closed, [1 40], Fs);

signal_open = detrend(signal_open);
signal_open = bandpass(signal_open, [1 40], Fs);


% Use Welch's method
win = hanning(2048);
noverlap = 512;
nfft = 2048;

[pxx_closed,f] = pwelch(signal_closed, win, noverlap, nfft, Fs);
[pxx_open,~] = pwelch(signal_open, win, noverlap, nfft, Fs);


% Plot
figure;

plot(f, pow2db(pxx_closed), 'LineWidth', 1.5); hold on;
plot(f, pow2db(pxx_open),   'LineWidth', 1.5);

xlim([0 40]); % EEG bands up to 40 Hz
xlabel('Frequency (Hz)');
ylabel('Power/Frequency (dB/Hz)');
title('Power Spectral Density (Welch)');
legend('Eyes Closed','Eyes Open');
grid on;