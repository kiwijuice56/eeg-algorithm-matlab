% Testing: Plotting the oddball task
figure; hold on;

Fs = 256; 
channel = 2;
cutoff = 8000; % Make the plot smaller and easier to handle
trial = "data\app_sample\eric_3.json";


% task_start_time and task_end time contain the unix timestamps (floats)
% corresponding to the beginning and end of the data window

% stimulus_times contains an array of unix timestamps for the appearance
% of every stimuli, between the start and end

% eeg_signal spans from start to end, evenly spaced

eeg_data = read_from_json_file_app(trial, "reaction", "notch_filtered_eeg");
eeg_signal = eeg_data.notch_filtered_eeg.data(channel, :);

stimulus_data = read_from_json_file_app(trial, "reaction", "stimulus");
stimulus_times = stimulus_data.stimulus_unix_time;

response_data = read_from_json_file_app(trial, "reaction", "response");
response_times = response_data.response_unix_time;

task_data = read_from_json_file_app(trial, "reaction", "task");
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
title('Reaction test EEG sample (Eric, left forehead)');

% overlay vertical lines at each stimulus time that falls within plotted range
xlims = [t(1), t(end)];
idx1 = find(stimulus_times >= xlims(1) & stimulus_times <= xlims(2));
idx2 = find(response_times >= xlims(1) & response_times <= xlims(2));

for k = 1:numel(idx1)
    x1 = stimulus_times(idx1(k));
    x2 = response_times(idx2(k));
    line([x1 x1], ylim, 'Color', [1 0 0], 'LineStyle', '--', 'LineWidth', 1);
    line([x2 x2], ylim, 'Color', [0.2, 0.5, 1], 'LineStyle', '-', 'LineWidth', 1);
end

% ensure axes limits unchanged except y as set
xlim(xlims);

