% Testing: Finding alpha peak from eyes closed data

Fs = 256; 
win = hanning(512);
noverlap = 256;
nfft = 2048; 
channel = 1;
rereference = false;

figure; hold on;

trials = {'eyes_closed_long'};
labels = {'Eyes closed'};
for trialnum = 1:length(trials) 
    trial = trials{trialnum};

    signals = read_from_json_file_raw(sprintf("data/pc/eric_alfaro/%s.json", trial), "eeg");
    signal = signals.eeg.data(channel, :);
    signal = detrend(signal); 
    
    [pxx, f] = pwelch(signal, win, noverlap, nfft, Fs);
    
    %pxx_smooth = movmean(pxx, 2);

    plot(f, pow2db(pxx), 'DisplayName', labels{trialnum}); 
end

title('Muse Headband: Alpha peak (left ear electrode, preset 1046)');
xlim([0 30]);
xlabel('Frequency (Hz)');
ylabel('Power/Frequency (dB/Hz)');
grid on;
legend;