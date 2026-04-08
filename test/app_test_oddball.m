% Testing: Plotting the oddball task
figure; hold on;

Fs = 256; 
channel = 1;
cutoff = 3000; % Make the plot smaller and easier to handle
trial = "data\app_sample\fletcher_1.json";


% task_start_time and task_end time contain the unix timestamps (floats)
% corresponding to the beginning and end of the data window

% stimulus_times contains an array of unix timestamps for the appearance
% of every stimuli, between the start and end

% eeg_signal spans from start to end, evenly spaced

eeg_data = read_from_json_file_app(trial, "oddball", "notch_filtered_eeg");
eeg_signal = eeg_data.notch_filtered_eeg.data(channel, :);

stimulus_data = read_from_json_file_app(trial, "oddball", "stimulus");
stimulus_times = stimulus_data.stimulus_unix_time;
stimulus_labels = stimulus_data.stimulus_label;

task_data = read_from_json_file_app(trial, "oddball", "task");
task_start_time = task_data.task_start_unix_time;
task_end_time = task_data.task_end_unix_time;


% create time vector for eeg_signal between task start and end
nSamples = numel(eeg_signal);
t = linspace(task_start_time, task_end_time, nSamples);

% limit to cutoff samples for plotting if desired
if cutoff > 0 && cutoff < nSamples
    t = t(1:cutoff);
    sig = eeg_signal(1:cutoff);
else
    sig = eeg_signal;
end

% plot EEG signal
plot(t, sig, 'Color', [0.35 0.7 0.9]);
xlabel('Unix Time (s)');
ylabel('EEG amplitude');
title('Oddball EEG sample (Fletcher, left ear)');

% overlay vertical lines at each stimulus time that falls within plotted range
xlims = [t(1), t(end)];
idx = find(stimulus_times >= xlims(1) & stimulus_times <= xlims(2));
for k = 1:numel(idx)
    x = stimulus_times(idx(k));
    lbl = stimulus_labels(idx(k));
    if strcmpi(lbl, "rare")
        col = [0.5 0 0.5]; % purple
    else
        col = [0 0.5 0];   % green
    end
    line([x x], ylim, 'Color', col, 'LineStyle', '--', 'LineWidth', 1);
end

% ensure axes limits unchanged except y as set
xlim(xlims);

