% Testing: Visualizing alpha peak when eyes are closed

Fs = 256; 
win = hanning(2048);
noverlap = 512;
nfft = 2048;
channel = 1;
rereference = false;

figure; hold on;

trials = {'eyes_open_3', 'eyes_closed_3'};
for trialnum = 1:length(trials) 
    trial = trials{trialnum};

    % Read data
    signals = read_from_json_file_raw(sprintf("data/eric_alfaro/%s.json", trial), "eeg");
    
    if (rereference) 
        EEG = eeg_emptyset;
        EEG.data = [signals.eeg.data(1:4,:)];
        EEG.nbchan = 4;
        EEG.pnts = size(signals.eeg.time, 1);
        EEG.trials = 1;
        EEG.srate = Fs;
        EEG.times = (0:length(signals.eeg.time)-1) / Fs;
        EEG = eeg_checkset(EEG);
        
        EEG = pop_reref(EEG, []);

        signal = EEG.data(channel, :);
    else 
        signal = signals.eeg.data(channel, :);
    end

    [pxx, f] = pwelch(signal, win, noverlap, nfft, Fs);
    plot(f, pow2db(pxx), 'DisplayName', replace(trial, "_", " "));
    
end

title('EEG PSD');
xlim([0 40]);
xlabel('Frequency (Hz)');
ylabel('Power/Frequency (dB/Hz)');
grid on;
legend;