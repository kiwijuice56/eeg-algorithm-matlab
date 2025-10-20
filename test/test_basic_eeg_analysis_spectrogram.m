Fs = 256; 
channel = 1;
window = 256; % Length of each segment in samples
noverlap = 128; % Overlap between segments
nfft = 512; % Number of FFT points
rereference = false;

figure; hold on;

trials = {'eyes_open_then_closed_4'};
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
    
    spectrogram(signal, hanning(window), noverlap, nfft, Fs, 'yaxis');
 
end

title('EEG Spectrogram (left ear)');
ylim([3 60]); 
clim([-30 50]); 