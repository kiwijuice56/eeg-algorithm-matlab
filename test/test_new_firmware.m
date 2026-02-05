% Testing: Visualizing built-in scores

% Read data
signals = read_from_json_file_raw("data/firmware_timestamp_test_1036.json", "eeg");

% Prepare figure
figure; hold on;
legendEntries = {};

% Plot signals
n = 128;

% Start time at 0 and convert to seconds
timestamps = signals.eeg.time(1:n);
timestamps = timestamps - timestamps(1);
timestamps(1)
timestamps(2)
timestamps = timestamps / 1e6;


% Evenly spaced timestamps
generatedTimestamps = (0:n-1) / 256;

% Create two vertically offset plots so lines do not overlap
offset = max(abs(signals.eeg.data(2,1:n))) * 2;

% First subplot (top)
ax1 = subplot(2,1,1);
plot(ax1, timestamps, signals.eeg.data(2, 1:n), '-o', 'MarkerSize', 3, 'LineWidth', 1);
xlabel('Time (s)');
ylabel('Amplitude (microvolts)');
title('EEG with Muse-provided timestamps (3.1.19 firmware, newest Windows SDK)');
grid on;

% Second subplot (bottom) with vertical offset
ax2 = subplot(2,1,2);
plot(ax2, generatedTimestamps, signals.eeg.data(2, 1:n) + offset, '-o', 'MarkerSize', 3, 'LineWidth', 1);
xlabel('Time (s)');
ylabel('Amplitude (microvolts)');
title('EEG assuming evenly spaced data points at 256 Hz');
grid on;

% Link x-axes
linkaxes([ax1, ax2], 'x');

% Make y-ticks the same by offsetting ax2's ticks
yticks_ax1 = get(ax1, 'YTick');
set(ax2, 'YTick', yticks_ax1 + offset);
set(ax2, 'YTickLabel', yticks_ax1);  % Display the original tick values