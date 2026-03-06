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

    % PSD
    signals = read_from_json_file_raw(sprintf("data/pc/eric_alfaro/%s.json", trial), "eeg");
    signal = signals.eeg.data(channel, :);
    signal = detrend(signal); 
    [pxx, f] = pwelch(signal, win, noverlap, nfft, Fs);
   % plot(f, pow2db(pxx), 'DisplayName', labels{trialnum}); 

    % FFT
    N = length(signal);          % Number of samples
    X = fft(signal);             % Compute FFT
    X = X(1:floor(N/2));         % Keep only positive frequencies
    f = (0:floor(N/2)-1)*(Fs/N); % Frequency vector

    magX = abs(X);

    order = 3; 
    framelen = 63;
    magX_smooth = sgolayfilt(magX, order, framelen);

    plot(f, magX_smooth, 'DisplayName', labels{trialnum});
end

title('Muse Headband: Alpha peak (left ear electrode, preset 1046)');
xlim([3 20]);
xlabel('Frequency (Hz)');
ylabel('Power/Frequency (dB/Hz)');
grid on;
legend;