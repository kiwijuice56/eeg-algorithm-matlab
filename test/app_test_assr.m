Fs = 256;
channel = 1;
trial = "data\app_sample\eric_2.json";
signals = read_from_json_file_app(trial, "assr_listening", "eeg");
signal = signals.eeg.data(channel, :);

% Split into two halves
half = floor(length(signal) / 2);
sig_40 = signal(1:half);
sig_80 = signal(half+1:end);

% welch PSD
win      = hanning(2048);
noverlap = 1024;
nfft     = 4096;
[pxx_40, f] = pwelch(sig_40, win, noverlap, nfft, Fs);
[pxx_80, ~] = pwelch(sig_80, win, noverlap, nfft, Fs);

figure;

% 40 Hz stimulus 
subplot(2,1,1); hold on;
plot(f, pow2db(pxx_40), 'b', 'LineWidth', 1.2, 'DisplayName', '40 Hz ASSR');
xline(40, '--r', '40 Hz stimulus', ...
    'LabelVerticalAlignment', 'bottom', 'LineWidth', 1.5);
xlim([1 100]);
grid on; legend;
xlabel('Frequency (Hz)');
ylabel('Power/Frequency (dB/Hz)');
title('PSD of 40 Hz ASSR stimulus (Fletcher)');

% 80 Hz stimulus
subplot(2,1,2); hold on;
plot(f, pow2db(pxx_80), 'm', 'LineWidth', 1.2, 'DisplayName', '80 Hz ASSR');
xline(80, '--r', '80 Hz stimulus', ...
    'LabelVerticalAlignment', 'bottom', 'LineWidth', 1.5);
xlim([1 100]);
grid on; legend;
xlabel('Frequency (Hz)');
ylabel('Power/Frequency (dB/Hz)');
title('PSD of 80 Hz ASSR stimulus (Fletcher)');