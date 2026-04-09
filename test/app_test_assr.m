Fs = 256;
channel = 4;
trial = "data\app_sample\eric_3.json";

% Load EEG
eeg_data   = read_from_json_file_app(trial, "assr_listening", "eeg");
eeg_signal = eeg_data.eeg.data(channel, :);

% Load timestamps
stimulus_data   = read_from_json_file_app(trial, "assr_listening", "stimulus");
stimulus_times  = stimulus_data.stimulus_unix_time;  % [high_start, rest_start, low_start]
task_data       = read_from_json_file_app(trial, "assr_listening", "task");
task_start_time = task_data.task_start_unix_time;
task_end_time   = task_data.task_end_unix_time;

% Convert unix timestamps to sample indices
% eeg_signal is evenly sampled over [task_start_time, task_end_time]
total_samples = length(eeg_signal);
total_duration = task_end_time - task_start_time;  % seconds

unix_to_sample = @(t) round((t - task_start_time) / total_duration * total_samples);

% stimulus_times(1) = 40_hz_high start (ignore, assume instantaneous)
% stimulus_times(2) = rest start      -> end of high condition
% stimulus_times(3) = 40_hz_low start -> end of rest, start of low condition
rest_start_sample = unix_to_sample(stimulus_times(2));
low_start_sample  = unix_to_sample(stimulus_times(3));

sig_high = eeg_signal(1               : rest_start_sample - 1);
sig_low  = eeg_signal(low_start_sample : end);

fprintf('High condition: %.1f s\n', length(sig_high) / Fs);
fprintf('Low condition:  %.1f s\n', length(sig_low)  / Fs);

% Welch PSD
win      = hanning(2048);
noverlap = 1024;
nfft     = 4096;
[pxx_high, f] = pwelch(sig_high, win, noverlap, nfft, Fs);
[pxx_low,  ~] = pwelch(sig_low,  win, noverlap, nfft, Fs);

delta_db = pow2db(pxx_high) - pow2db(pxx_low);

figure;

% high volume
subplot(3,1,1); hold on;
plot(f, pow2db(pxx_high), 'b', 'LineWidth', 1.2, 'DisplayName', 'High volume');
xline(40, '--r', '40 Hz', 'LabelVerticalAlignment', 'bottom', 'LineWidth', 1.5);
xlim([15, 45]); grid on; legend;
ylabel('Power/Frequency (dB/Hz)');
title('40 Hz ASSR high volume');
legend('off');

% low volume
subplot(3,1,2); hold on;
plot(f, pow2db(pxx_low), 'm', 'LineWidth', 1.2, 'DisplayName', 'Low volume');
xline(40, '--r', '40 Hz', 'LabelVerticalAlignment', 'bottom', 'LineWidth', 1.5);
xlim([15 45]); grid on; legend;
ylabel('Power/Frequency (dB/Hz)');
title('40 Hz ASSR low volume');
legend('off');

% delta
subplot(3,1,3); hold on;
plot(f, delta_db, 'k', 'LineWidth', 1.2, 'DisplayName', 'High - Low (dB)');
xline(40, '--r', '40 Hz', 'LabelVerticalAlignment', 'bottom', 'LineWidth', 1.5);
yline(0, '--', 'Color', [0.5 0.5 0.5]);
xlim([15 45]); grid on; legend;
xlabel('Frequency (Hz)');
ylabel('Power difference (dB)');
title('40 Hz ASSR delta (high - low)');
legend('off');