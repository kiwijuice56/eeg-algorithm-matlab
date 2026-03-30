% Testing: Plotting the oddball task
figure; hold on;

Fs = 256; 
channel = 1;
cutoff = 3000; % Make the plot smaller and easier to handle
trial = "data\app_sample\40232b95-d742-40c8-acb0-32370e45662c.json";

eeg_data = read_from_json_file_app(trial, "oddball", "eeg");
stimulus_data = read_from_json_file_app(trial, "oddball", "stimulus_times");

eeg_signal = eeg_data.eeg.data(channel, :);
plot(eeg_timestamps, eeg_signal);

stimulus_signal = signals.stimulus_data.data(:);


