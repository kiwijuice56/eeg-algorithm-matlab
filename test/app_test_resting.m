Fs = 256;
channel = 1;
trial = "data\pilot_young_2\cc3e4b32-2aef-48b3-9cf6-5f3f65eb010b.json";
signals = read_from_json_file_app(trial, "no_stimulus", "eeg");
signal = signals.eeg.data(channel, :);

% welch PSD
win     = hanning(2048);  
noverlap = 1024;
nfft    = 4096;
[pxx, f] = pwelch(signal, win, noverlap, nfft, Fs);

% light smoothing
smooth_bins = 3;   
pxx_smooth = movmean(pxx, smooth_bins);

% find alpha peak (7-13 Hz) on smoothed PSD
alpha_mask = f >= 7 & f <= 13;
f_alpha    = f(alpha_mask);
pxx_alpha  = pxx_smooth(alpha_mask);
[~, idx]   = max(pxx_alpha);
peak_freq  = f_alpha(idx);

% plot
figure; hold on;
plot(f, pow2db(pxx),        'Color', [0.6 0.6 0.6], 'DisplayName', 'Raw PSD');
plot(f, pow2db(pxx_smooth), 'b', 'LineWidth', 1.5,  'DisplayName', 'Smoothed PSD');
xline(peak_freq, '--r', sprintf('%.2f Hz', peak_freq), ...
    'LabelVerticalAlignment', 'bottom', 'LineWidth', 1.5, 'DisplayName', 'Alpha peak');
xlim([1 30]);
ylim([-10, 15]);
grid on; legend;
xlabel('Frequency (Hz)');
ylabel('Power/Frequency (dB/Hz)');
title('Resting state PSD (Healthy young, left ear)');