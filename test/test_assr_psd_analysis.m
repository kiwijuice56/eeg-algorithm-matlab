% Testing: Comparing EEG from ASSR trials

Fs = 256; 
win = hanning(2048);
noverlap = 512;
nfft = 2048;
channel = 1;
rereference = false;

figure; hold on;

trials = {'no_stimulus_3', 'stimulus_no_headphones_3'};
labels = {'Silent', '40 Hz Clicking'};
for trialnum = 1:length(trials) 
    trial = trials{trialnum};

    signals = read_from_json_file_raw(sprintf("data/40_hz_assr/%s.json", trial), "eeg");
    signal = signals.eeg.data(channel, :);

    [pxx, f] = pwelch(signal, win, noverlap, nfft, Fs);
    plot(f, pow2db(pxx), 'DisplayName', labels{trialnum}); 
end

title('Muse Headband: Auditory Steady-State Response (left ear electrode, preset 1046, 90 second recording, laptop speaker)');
xlim([3 50]);
xlabel('Frequency (Hz)');
ylabel('Power/Frequency (dB/Hz)');
grid on;
legend;