% Testing: Finding alpha peak from eyes closed data (or ASSR listening)
figure; hold on;

Fs = 256; 
channel = 1;
trial = "data\app_sample\40232b95-d742-40c8-acb0-32370e45662c.json";

signals = read_from_json_file_app(trial, "assr_listening", "eeg");
signal = signals.eeg.data(channel, :);
% signal = signal(length(signal) / 2 : length(signal)); % hacky way to split up the ASSR
signal = detrend(signal); 

% FFT and PSD params
win = hanning(1024);
noverlap = 512;
nfft = 2048; 

% PSD
[pxx, f] = pwelch(signal, win, noverlap, nfft, Fs);
plot(f, pow2db(pxx)); 

% FFT
N = length(signal);          % Number of samples
X = fft(signal);             % Compute FFT
X = X(1:floor(N/2));         % Keep only positive frequencies
f = (0:floor(N/2)-1)*(Fs/N); % Frequency vector

% commented out to only show PSD
% plot(f, abs(X));

title('Frequency domain plot (PSD, left ear, 60 seconds)');
xlim([3 80]);
ylim([-20 20]);

xlabel('Frequency (Hz)');
ylabel('Power/Frequency (dB/Hz)');
grid on;
legend;