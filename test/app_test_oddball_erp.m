% ERP Analysis of Oddball Task
Fs = 256;
channel = 1;
trial = "data\app_sample\eric_2.json";

% epoch parameters 
pre_stim_ms  = 200;
post_stim_ms = 800;
trim = 1;  % remove first N stimuli overall 

pre_samples  = round(pre_stim_ms  / 1000 * Fs);
post_samples = round(post_stim_ms / 1000 * Fs);
epoch_samples = pre_samples + post_samples;
t_epoch = linspace(-pre_stim_ms, post_stim_ms, epoch_samples);

% load data 
eeg_data = read_from_json_file_app(trial, "oddball", "notch_filtered_eeg");
eeg_signal = eeg_data.notch_filtered_eeg.data(channel, :);

stimulus_data = read_from_json_file_app(trial, "oddball", "stimulus");
stimulus_times  = stimulus_data.stimulus_unix_time;
stimulus_labels = stimulus_data.stimulus_label;

task_data = read_from_json_file_app(trial, "oddball", "task");
task_start_time = task_data.task_start_unix_time;
task_end_time   = task_data.task_end_unix_time;

% create time vector for eeg_signal between task start and end
nSamples = numel(eeg_signal);
t = linspace(task_start_time, task_end_time, nSamples);

% apply trim
stimulus_times  = stimulus_times(trim+1:end);
stimulus_labels = stimulus_labels(trim+1:end);

% epoch extraction 
common_epochs = [];
rare_epochs   = [];
for k = 1:numel(stimulus_times)
    stim_t = stimulus_times(k);
    lbl = stimulus_labels(k);

    [~, stim_idx] = min(abs(t - stim_t));

    idx_start = stim_idx - pre_samples;
    idx_end = stim_idx + post_samples - 1;

    if idx_start < 1 || idx_end > nSamples
        continue;
    end

    epoch = eeg_signal(idx_start:idx_end);
    epoch = epoch - mean(epoch(1:pre_samples));  % baseline correct

    if strcmpi(lbl, "rare")
        rare_epochs(end+1, :) = epoch;
    else
        common_epochs(end+1, :) = epoch;
    end
end

% compute ERPs
common_erp = mean(common_epochs, 1);
rare_erp = mean(rare_epochs,   1);

% plot 
figure; hold on;
plot(t_epoch, common_erp, 'Color', [0 0.5 0],   'LineWidth', 2, 'DisplayName', sprintf('Common (n=%d)', size(common_epochs,1)));
plot(t_epoch, rare_erp,   'Color', [0.5 0 0.5], 'LineWidth', 2, 'DisplayName', sprintf('Rare (n=%d)',   size(rare_epochs,1)));
xline(0, 'k--', 'Stimulus Onset', 'LineWidth', 1.2);
xlabel('Time (ms)');
ylabel('EEG Amplitude (baseline corrected)');
title('Oddball ERP (Eric, left ear)');
legend('Location', 'best');
grid on;