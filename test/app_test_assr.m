Fs = 256;
channel = 4;
trial_file = "data\app_sample\preset_1022.json";
% Load Data
eeg_data       = read_from_json_file_app(trial_file, "assr_listening", "eeg");
eeg_signal     = eeg_data.eeg.data(channel, :);
stimulus_data  = read_from_json_file_app(trial_file, "assr_listening", "stimulus");
task_data      = read_from_json_file_app(trial_file, "assr_listening", "task");
% Extract Timestamps and Labels
stim_times  = stimulus_data.stimulus_unix_time;
stim_labels = stimulus_data.stimulus_label;
task_start  = task_data.task_start_unix_time;
task_end    = task_data.task_end_unix_time;
% Time-to-Sample Mapping
total_samples  = length(eeg_signal);
total_duration = task_end - task_start;
unix_to_sample = @(t) round((t - task_start) / total_duration * total_samples);
% Processing Setup
num_markers = length(stim_times);
win      = hanning(2048);
noverlap = 1024;
nfft     = 4096;

figure('Name', 'ASSR Grid Results (preset 1022)');
fprintf('Processing trials...\n');

for i = 1:num_markers
    current_label = stim_labels{i};
    
    if contains(current_label, 'rest', 'IgnoreCase', true)
        continue;
    end
    
    % Determine grid position
    if contains(current_label, '40_hz_high'), sp_idx = 1;
    elseif contains(current_label, '40_hz_low'),  sp_idx = 3;
    elseif contains(current_label, '25_hz_high'), sp_idx = 2;
    elseif contains(current_label, '25_hz_low'),  sp_idx = 4;
    else, continue;
    end
    
    start_idx = unix_to_sample(stim_times(i));
    if i < num_markers
        end_idx = unix_to_sample(stim_times(i+1)) - 1;
    else
        end_idx = total_samples;
    end
    
    segment = eeg_signal(max(1, start_idx):min(end_idx, total_samples));
    
    if contains(current_label, '40')
        target_freq = 40;
    elseif contains(current_label, '25')
        target_freq = 25;
    else
        target_freq = 40;
    end
    
    [pxx, f] = pwelch(segment, win, noverlap, nfft, Fs);
    
    subplot(2, 2, sp_idx);
    hold on;
    % xline(target_freq, '--r', sprintf('%d Hz', target_freq), ...
    %     'LabelVerticalAlignment', 'bottom', 'LineWidth', 1.5);
    plot(f, pow2db(pxx), 'LineWidth', 1.2);
    
    
    xlim([3, 50]);
    ylim([-10, 15]);
    grid on;
    if sp_idx > 2, xlabel('Frequency (Hz)'); end
    if mod(sp_idx, 2) ~= 0, ylabel('Power/Frequency (dB/Hz)'); end
    title(strrep(current_label, '_', ' '));
    
    fprintf('Processed %s: %.1f s\n', current_label, length(segment) / Fs);
end