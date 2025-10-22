% Testing: Visualizing built-in data

% Read data
Fs = 256;
signals = read_from_json_file_raw("data/eric_alfaro/eyes_open_then_closed_4.json", "eeg");

% Create EEG struct
EEG = eeg_emptyset;
EEG.data = [signals.eeg.data(1:4,:)];
EEG.nbchan = 4;
EEG.pnts = length(signals.eeg.time);
EEG.trials = 1;
EEG.srate = 256;
EEG.times = signals.eeg.time; % (0:length(signals.eeg.time)-1) / Fs;
EEG = eeg_checkset(EEG);

% EEG = pop_reref(EEG, []);

% Prepare figure
figure; hold on;

% Plot signals
n = Fs;
plot((EEG.times(1:n) - EEG.times(1)) / 1e3, EEG.data(2, 1:n), 'LineWidth', 1);

% Finalize plot
xlabel('Time (s)');
ylabel('Amplitude');
title('Basic EEG Plotting: Muse timestamps');
grid on;
hold off;
