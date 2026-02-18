% Testing: Finding alpha peak from eyes closed data

Fs = 256; 
win = hanning(1024);
noverlap = 512;
nfft = 1024;
channel = 1;
rereference = false;

figure; hold on;

trials = {'eyes_closed_4'};
labels = {'Eyes closed'};
for trialnum = 1:length(trials) 
    trial = trials{trialnum};

    signals = read_from_json_file_raw(sprintf("data/eric_alfaro/%s.json", trial), "notch_filtered_eeg");
    signal = signals.notch_filtered_eeg.data(channel, :);
    signal = detrend(signal); 

    [pxx, f] = pwelch(signal, win, noverlap, nfft, Fs);
    plot(f, pow2db(pxx), 'DisplayName', labels{trialnum}); 
end

title('Muse Headband: Alpha peak (left ear electrode, preset 1046)');
xlim([0 30]);
xlabel('Frequency (Hz)');
ylabel('Power/Frequency (dB/Hz)');
grid on;
legend;