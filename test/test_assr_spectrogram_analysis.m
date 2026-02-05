Fs = 256; 
channel = 1;
window = 128; % Length of each segment in samples
noverlap = 64; % Overlap between segments
nfft = 512; % Number of FFT points

trials = {'no_stimulus', 'stimulus_2'};
figure;

for trialnum = 1:length(trials) 
    subplot(1,length(trials),trialnum); % place spectrograms side by side
    trial = trials{trialnum};
    signals = read_from_json_file_raw(sprintf("data/40_hz_assr/%s.json", trial), "eeg");
    signal = signals.eeg.data(channel, :);
    spectrogram(signal, hanning(window), noverlap, nfft, Fs, 'yaxis');
    title(sprintf('EEG Spectrogram (left forehead) - %s', trials{trialnum}));
    ylim([15 55]); 
    clim([-50 15]); 
end