% Testing: Finding alpha peak from eyes closed data

Fs = 256; 
win = hanning(1024);
noverlap = 512;
nfft = 2048; 
channel = 1;
time = 60;

figure; hold on;

% trials = {'1021_fletcher_data', '1032_fletcher_data_1', '1032_fletcher_data_2'};
% labels = {'Sample 1: 1021', 'Sample 2: 1032', 'Sample 3: 1032'};

% trials = {'1021_fletcher_data', '1032_fletcher_data_1', '1032_fletcher_data_2'};
% labels = {'Sample 1: 1021', 'Sample 2: 1032', 'Sample 3: 1032'};
for trialnum = 1:length(trials) 
    trial = trials{trialnum};

    signals = read_from_json_file_raw(sprintf("data/fletcher_sample/%s.json", trial), "eeg");
    signal = signals.eeg.data(channel, :);
    signal = signal(1:Fs * time);

    % PSD
    [pxx, f] = pwelch(signal, win, noverlap, nfft, Fs);
    plot(f, pow2db(pxx), 'DisplayName', labels{trialnum}); 
end

title('Frequency domain plot (left ear electrode)');
xlim([0 80]);
xlabel('Frequency (Hz)');
ylabel('Power/Frequency (dB/Hz)');
grid on;
legend;