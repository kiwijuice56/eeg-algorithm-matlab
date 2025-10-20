% Testing: Visualizing built-in data

% Read data
signals = read_from_json_file_raw("data/eric_alfaro/eyes_open_then_closed_4.json", "eeg");

% Create EEG struct
EEG = eeg_emptyset;
EEG.data = [signals.eeg.data(1:4,:)];
EEG.nbchan = 4;
EEG.pnts = size(signals.eeg.time, 1);
EEG.trials = 1;
EEG.srate = 256;
EEG.times = signals.eeg.time;
EEG = eeg_checkset(EEG);

EEG = pop_reref(EEG, []);

% Prepare figure
figure; hold on;

% Plot signals
n = 600;
plot(signals.eeg.time(1:n), signals.eeg.data(2, 1:n), 'LineWidth', 1);
plot(EEG.times(1:n), EEG.data(2, 1:n), 'LineWidth', 1);

% Finalize plot
xlabel('Time (s)');
ylabel('Amplitude');
title('Basic EEG Plotting');
grid on;
hold off;
